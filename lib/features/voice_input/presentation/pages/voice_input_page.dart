import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../meal_tracking/presentation/bloc/meal_bloc.dart';
import '../bloc/voice_bloc.dart';
import 'voice_confirmation_page.dart';

class VoiceInputPage extends StatefulWidget {
  final String userId;
  final DateTime date;

  const VoiceInputPage({super.key, required this.userId, required this.date});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage>
    with SingleTickerProviderStateMixin {
  final _speech = SpeechToText();

  _Status _status = _Status.idle;
  String _transcription = '';
  int _seconds = 0;
  Timer? _timer;
  String? _errorMessage;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.stop();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    setState(() {
      _status = _Status.initializing;
      _errorMessage = null;
    });
    final available = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
    );
    if (!mounted) return;
    if (available) {
      setState(() => _status = _Status.idle);
    } else {
      setState(() {
        _status = _Status.error;
        _errorMessage =
            'Reconnaissance vocale indisponible.\n'
            'Vérifiez que la permission Microphone est accordée '
            'dans les réglages de l\'appareil.';
      });
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) return;
    _stopTimer();
    _pulseCtrl.stop();
    setState(() {
      _status = _Status.error;
      _errorMessage = error.errorMsg == 'error_speech_timeout'
          ? 'Aucune parole détectée. Réessayez.'
          : 'Erreur : ${error.errorMsg}';
    });
  }

  void _onStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      if (_status == _Status.listening) {
        _stopRecording();
      }
    }
  }

  Future<void> _startRecording() async {
    // Guard: if STT not initialized, try again before listening
    if (!_speech.isAvailable) {
      await _initSpeech();
      if (!mounted || !_speech.isAvailable) return;
    }
    setState(() {
      _status = _Status.listening;
      _transcription = '';
      _seconds = 0;
      _errorMessage = null;
    });
    _pulseCtrl.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _transcription = result.recognizedWords);
        if (result.finalResult && _transcription.isNotEmpty) {
          _stopRecording();
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'fr_FR',
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _stopRecording() async {
    if (_status != _Status.listening) return;
    _stopTimer();
    _pulseCtrl.stop();
    setState(() => _status = _Status.stopping);
    await _speech.stop();
    if (!mounted) return;
    if (_transcription.trim().isEmpty) {
      setState(() {
        _status = _Status.idle;
        _errorMessage = 'Aucune parole détectée. Réessayez.';
      });
      return;
    }
    // Fire parsing in BLoC
    context.read<VoiceBloc>().add(VoiceParseRequested(_transcription));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _reset() {
    _stopTimer();
    _pulseCtrl.stop();
    context.read<VoiceBloc>().add(const VoiceResetRequested());
    setState(() {
      _status = _Status.idle;
      _transcription = '';
      _seconds = 0;
      _errorMessage = null;
    });
  }

  String get _timerLabel {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    _pulseCtrl.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceBloc, VoiceState>(
      listener: (ctx, state) {
        if (state is VoicePendingConfirmation) {
          final nav = Navigator.of(context);
          nav.push<bool>(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: ctx.read<VoiceBloc>()),
                  BlocProvider.value(value: ctx.read<MealBloc>()),
                ],
                child: VoiceConfirmationPage(
                  items: state.items,
                  transcription: state.transcription,
                  userId: widget.userId,
                  date: widget.date,
                ),
              ),
            ),
          ).then((saved) {
            if (!mounted) return;
            if (saved == true) {
              nav.pop();
            } else {
              _reset();
            }
          });
        } else if (state is VoiceError) {
          setState(() {
            _status = _Status.idle;
            _errorMessage = state.message;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgWhite,
        appBar: AppBar(
          title: Text('Saisie vocale', style: AppTypography.h3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Instruction
                Text(
                  _instructionText,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Animated mic + label
                _buildMicButton(),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _micLabel,
                    key: ValueKey(_status),
                    style: AppTypography.caption.copyWith(
                      color: _status == _Status.listening
                          ? AppColors.error
                          : _status == _Status.error
                              ? Colors.orange
                              : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Timer
                if (_status == _Status.listening)
                  Text(
                    _timerLabel,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                // Transcription
                if (_transcription.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '"$_transcription"',
                      style: AppTypography.body.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // Parsing loader
                if (_status == _Status.stopping) ...[
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Analyse en cours…', style: AppTypography.caption),
                ],

                // Error
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Examples
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exemples de phrases',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final ex in [
                        '"2 œufs brouillés et une tranche de pain"',
                        '"Un bol de riz avec 120g de poulet grillé"',
                        '"Une pomme, un yaourt et un verre de lait"',
                        '"3 cs de houmous avec des carottes"',
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            ex,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _micLabel => switch (_status) {
    _Status.idle        => 'Appuyer pour parler',
    _Status.initializing => 'Initialisation…',
    _Status.listening   => 'Appuyer pour arrêter',
    _Status.stopping    => 'Traitement…',
    _Status.error       => 'Appuyer pour réessayer',
  };

  String get _instructionText {
    return switch (_status) {
      _Status.idle => 'Appuyez sur le micro et décrivez votre repas',
      _Status.initializing => 'Initialisation…',
      _Status.listening => 'Parlez maintenant…',
      _Status.stopping => 'Traitement…',
      _Status.error => 'Une erreur est survenue',
    };
  }

  Widget _buildMicButton() {
    final isListening = _status == _Status.listening;
    final isDisabled = _status == _Status.initializing ||
        _status == _Status.stopping;
    final isError = _status == _Status.error;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : isListening
              ? _stopRecording
              : _startRecording,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) {
          final scale = isListening ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                if (isListening)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                // Button
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? AppColors.error
                        : isError
                            ? Colors.orange
                            : isDisabled
                                ? AppColors.border
                                : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? AppColors.error : AppColors.primary)
                            .withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening
                        ? Icons.stop_rounded
                        : isError
                            ? Icons.refresh_rounded
                            : isDisabled
                                ? Icons.hourglass_top_rounded
                                : Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _Status { idle, initializing, listening, stopping, error }
