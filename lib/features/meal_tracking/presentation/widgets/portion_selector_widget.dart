import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/food_portion.dart';

/// Section 1 — Portions standardisées issues de CIQUAL (ou carte statique).
/// Affiche une liste de portions cliquables avec leur équivalent en grammes.
class PortionSelectorWidget extends StatefulWidget {
  final List<FoodPortion> portions;
  final double? selectedGrams;
  final void Function(double grams) onSelected;

  const PortionSelectorWidget({
    super.key,
    required this.portions,
    required this.onSelected,
    this.selectedGrams,
  });

  @override
  State<PortionSelectorWidget> createState() => _PortionSelectorWidgetState();
}

class _PortionSelectorWidgetState extends State<PortionSelectorWidget> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Portions suggérées', style: AppTypography.h3.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        ...List.generate(widget.portions.length, (i) {
          final p = widget.portions[i];
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              widget.onSelected(p.grams);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryPale : AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.label, style: AppTypography.bodyMedium),
                        if (p.description.isNotEmpty)
                          Text(p.description, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${p.grams.toInt()} g',
                      style: AppTypography.label.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
