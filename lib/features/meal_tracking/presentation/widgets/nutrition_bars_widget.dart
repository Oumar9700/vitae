import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

class MacroBarWidget extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final String unit;

  const MacroBarWidget({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  double get _ratio => target > 0 ? (consumed / target).clamp(0.0, 1.5) : 0;

  Color get _barColor {
    final ratio = target > 0 ? consumed / target : 0;
    if (ratio > 1.2) return AppColors.error;
    if (ratio > 1.05) return AppColors.accent;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? consumed / target : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.label),
            const Spacer(),
            RichText(
              text: TextSpan(
                style: AppTypography.label,
                children: [
                  TextSpan(
                    text: '${_formatNum(consumed)}$unit',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text: ' / ${_formatNum(target)}$unit',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: '  ${(ratio * 100).toInt()}%',
                    style: TextStyle(
                      color: ratio > 1.2 ? AppColors.error : ratio > 0.8 ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _ratio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation(_barColor),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNum(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class CalorieProgressWidget extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieProgressWidget({
    super.key,
    required this.consumed,
    required this.target,
  });

  double get _ratio => target > 0 ? (consumed / target).clamp(0.0, 1.5) : 0;

  Color get _color {
    if (_ratio > 1.2) return AppColors.error;
    if (_ratio > 1.0) return AppColors.accent;
    if (_ratio >= 0.8) return AppColors.primary;
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${consumed.toInt()}',
              style: AppTypography.calorieDisplay.copyWith(color: _color),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '/ ${target.toInt()} kcal',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          remaining >= 0
              ? 'Reste ${remaining.toInt()} kcal'
              : 'Surplus de ${remaining.abs().toInt()} kcal',
          style: AppTypography.label.copyWith(
            color: remaining < 0 ? AppColors.error : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _ratio.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation(_color),
              minHeight: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class HealthIndicatorChip extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String unit;

  const HealthIndicatorChip({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
  });

  Color get _color {
    final ratio = value / max;
    if (ratio > 1.2) return AppColors.error;
    if (ratio > 0.9) return AppColors.accent;
    return AppColors.primary;
  }

  String get _grade {
    final ratio = value / max;
    if (ratio <= 0.7) return 'A';
    if (ratio <= 0.85) return 'B';
    if (ratio <= 1.0) return 'C';
    if (ratio <= 1.2) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _grade,
            style: AppTypography.h3.copyWith(color: _color, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${_formatNum(value)}${unit}/${_formatNum(max)}${unit}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _formatNum(double v) => v >= 100 ? v.toInt().toString() : v.toStringAsFixed(1);
}
