import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/food.dart';

/// Section 3 — Slider visuel avec mise à jour nutrition en temps réel.
class QuantitySliderWidget extends StatefulWidget {
  final Food food;
  final double initialGrams;
  final void Function(double grams) onChanged;

  const QuantitySliderWidget({
    super.key,
    required this.food,
    required this.initialGrams,
    required this.onChanged,
  });

  @override
  State<QuantitySliderWidget> createState() => _QuantitySliderWidgetState();
}

class _QuantitySliderWidgetState extends State<QuantitySliderWidget> {
  late double _grams;
  static const double _max = 500;

  @override
  void initState() {
    super.initState();
    _grams = widget.initialGrams.clamp(10, _max);
  }

  Nutrition get _nutrition => widget.food.nutritionForQuantity(_grams);

  @override
  Widget build(BuildContext context) {
    final fillRatio = (_grams / _max).clamp(0.0, 1.0);
    final nutrition = _nutrition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ajuster la quantité', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 12),

        // Barre de remplissage visuelle
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 10, color: AppColors.border),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 10,
                width: MediaQuery.of(context).size.width * fillRatio * 0.85,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primaryPale,
            trackHeight: 4,
          ),
          child: Slider(
            value: _grams,
            min: 10,
            max: _max,
            divisions: 49,
            label: '${_grams.toInt()} g',
            onChanged: (v) {
              setState(() => _grams = v);
              widget.onChanged(v);
            },
          ),
        ),

        // Aperçu nutrition en temps réel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_grams.toInt()} g',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
              Row(
                children: [
                  _MiniStat('${nutrition.calories.toInt()} kcal', AppColors.textPrimary),
                  const SizedBox(width: 10),
                  _MiniStat('P:${nutrition.proteinG.toStringAsFixed(0)}g', AppColors.chartProtein),
                  const SizedBox(width: 6),
                  _MiniStat('G:${nutrition.carbsG.toStringAsFixed(0)}g', AppColors.chartCarbs),
                  const SizedBox(width: 6),
                  _MiniStat('L:${nutrition.fatsG.toStringAsFixed(0)}g', AppColors.chartFats),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniStat(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600));
  }
}
