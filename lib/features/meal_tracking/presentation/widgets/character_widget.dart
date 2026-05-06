import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

enum CharacterMood { happy, neutral, warning, sad }

class CharacterWidget extends StatefulWidget {
  final double caloriesRatio; // 0.0 - 1.5+
  final bool proteinsLow;
  final bool sugarHigh;

  const CharacterWidget({
    super.key,
    required this.caloriesRatio,
    this.proteinsLow = false,
    this.sugarHigh = false,
  });

  @override
  State<CharacterWidget> createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CharacterMood get _mood {
    if (widget.caloriesRatio > 1.2) return CharacterMood.sad;
    if (widget.caloriesRatio >= 0.85) return CharacterMood.warning;
    if (widget.caloriesRatio >= 0.5 && !widget.proteinsLow && !widget.sugarHigh) {
      return CharacterMood.happy;
    }
    if (widget.proteinsLow || widget.sugarHigh) return CharacterMood.warning;
    return CharacterMood.neutral;
  }

  Color get _moodColor {
    switch (_mood) {
      case CharacterMood.happy: return AppColors.charHappy;
      case CharacterMood.warning: return AppColors.charWarning;
      case CharacterMood.sad: return AppColors.charSad;
      case CharacterMood.neutral: return AppColors.charNeutral;
    }
  }

  String get _moodMessage {
    switch (_mood) {
      case CharacterMood.happy: return '😊 Super équilibre!';
      case CharacterMood.warning:
        if (widget.sugarHigh) return '⚠️ Attention aux sucres!';
        if (widget.proteinsLow) return '💪 Protéines insuffisantes';
        return '🔶 Tu approches ton objectif';
      case CharacterMood.sad: return '😟 Objectif calorique dépassé';
      case CharacterMood.neutral: return '🌱 Continue à ajouter tes repas';
    }
  }

  IconData get _moodIcon {
    switch (_mood) {
      case CharacterMood.happy: return Icons.sentiment_very_satisfied_rounded;
      case CharacterMood.warning: return Icons.sentiment_neutral_rounded;
      case CharacterMood.sad: return Icons.sentiment_dissatisfied_rounded;
      case CharacterMood.neutral: return Icons.sentiment_satisfied_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fillRatio = widget.caloriesRatio.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnim.value),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _showAdviceDialog(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _moodColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: _moodColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),

                // Fill indicator (clipper)
                ClipOval(
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        // Background circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgLight,
                          ),
                        ),
                        // Fill (from bottom)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            height: 120 * fillRatio,
                            decoration: BoxDecoration(
                              color: _moodColor.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                        // Character icon
                        Center(
                          child: Icon(
                            _moodIcon,
                            size: 56,
                            color: _moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Percentage badge
                Positioned(
                  bottom: 4,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _moodColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(fillRatio * 100).toInt()}%',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _moodMessage,
            key: ValueKey(_moodMessage),
            style: AppTypography.label.copyWith(
              color: _moodColor == AppColors.charNeutral ? AppColors.textSecondary : _moodColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tape pour des conseils',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  void _showAdviceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AdviceSheet(mood: _mood, message: _moodMessage),
    );
  }
}

class _AdviceSheet extends StatelessWidget {
  final CharacterMood mood;
  final String message;

  const _AdviceSheet({required this.mood, required this.message});

  List<String> get _advices {
    switch (mood) {
      case CharacterMood.happy:
        return [
          '✅ Excellent équilibre nutritionnel aujourd\'hui!',
          '🥗 Continue sur cette lancée demain',
          '💧 N\'oublie pas de t\'hydrater',
        ];
      case CharacterMood.warning:
        return [
          '🥩 Ajoute des protéines: œufs, poulet, légumineuses',
          '🥦 Remplace les snacks sucrés par des fruits',
          '🌾 Préfère les glucides complexes (riz complet, avoine)',
        ];
      case CharacterMood.sad:
        return [
          '⚖️ Tu as dépassé ton objectif calorique',
          '🚶 Une courte marche après les repas aide à compenser',
          '🥤 Bois de l\'eau, évite les boissons sucrées',
          '🌙 Pour demain: commence par un petit-déjeuner léger',
        ];
      case CharacterMood.neutral:
        return [
          '🌟 La journée commence! Ajoute tes repas',
          '☀️ Un bon petit-déjeuner équilibré te donnera de l\'énergie',
          '📱 Pense à logger chaque repas pour un suivi précis',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conseils Vitae', style: AppTypography.h3),
          const SizedBox(height: 8),
          Text(message, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ..._advices.map((advice) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 4),
                    Expanded(child: Text(advice, style: AppTypography.body)),
                  ],
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
