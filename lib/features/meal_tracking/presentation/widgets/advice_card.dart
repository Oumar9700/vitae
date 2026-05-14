import 'package:flutter/material.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

/// An animated card showing a nutritional tip that auto-cycles.
/// Pass [advices] to provide a list of tip strings, or leave empty to use defaults.
class AdviceCard extends StatefulWidget {
  final List<String>? advices;
  final Duration cycleInterval;

  const AdviceCard({
    super.key,
    this.advices,
    this.cycleInterval = const Duration(seconds: 8),
  });

  @override
  State<AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<AdviceCard>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _fade;
  late final Animation<double> _opacity;

  static const List<String> _defaultAdvices = [
    'Boire 1,5–2 L d\'eau par jour améliore ton métabolisme et ta concentration.',
    'Les protéines favorisent la satiété : vise 1,6 g par kg de poids corporel.',
    'Mange lentement — il faut 20 min au cerveau pour sentir la satiété.',
    'Les fibres (légumes, légumineuses) nourrissent ton microbiote intestinal.',
    'Préfère les glucides complexes (avoine, patate douce) aux sucres rapides.',
    'Un petit-déjeuner riche en protéines réduit les fringales de l\'après-midi.',
    'Les graisses insaturées (avocat, noix, olive) sont essentielles au cerveau.',
    'Manger varié est plus important que d\'éviter un aliment en particulier.',
  ];

  List<String> get _advices => widget.advices ?? _defaultAdvices;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeInOut);
    _scheduleNext();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _scheduleNext() {
    Future.delayed(widget.cycleInterval, () {
      if (!mounted) return;
      _fade.reverse().then((_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % _advices.length);
        _fade.forward().then((_) => _scheduleNext());
      });
    });
  }

  void _next() {
    _fade.reverse().then((_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _advices.length);
      _fade.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryPale, AppColors.accentPale],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.tip, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil nutrition',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: _opacity,
                  child: Text(
                    _advices[_index],
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Next tip button
          GestureDetector(
            onTap: _next,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
