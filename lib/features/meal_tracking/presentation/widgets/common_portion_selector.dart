import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../data/datasources/portions_data_source.dart';

/// Section 2 — Trois boutons visuels : Petit / Moyen / Grand.
/// Zéro charge mentale : aucun chiffre à saisir avant de choisir.
class CommonPortionSelector extends StatefulWidget {
  final String foodName;
  final double? selectedGrams;
  final void Function(double grams) onSelected;

  const CommonPortionSelector({
    super.key,
    required this.foodName,
    required this.onSelected,
    this.selectedGrams,
  });

  @override
  State<CommonPortionSelector> createState() => _CommonPortionSelectorState();
}

class _CommonPortionSelectorState extends State<CommonPortionSelector> {
  int? _selected; // 0=small, 1=medium, 2=large

  @override
  Widget build(BuildContext context) {
    final sizes = PortionsService.getCommonSizes(widget.foodName);
    final options = [
      _PortionOption('Petite', sizes.small, Icons.remove_circle_outline_rounded, AppColors.accent),
      _PortionOption('Moyenne', sizes.medium, Icons.circle_outlined, AppColors.primary),
      _PortionOption('Grande', sizes.large, Icons.add_circle_outline_rounded, AppColors.chartFats),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quelle taille ?', style: AppTypography.h3.copyWith(fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) {
            final opt = options[i];
            final isSelected = _selected == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selected = i);
                  widget.onSelected(opt.grams);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? opt.color.withValues(alpha: 0.12) : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? opt.color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(opt.icon, color: isSelected ? opt.color : AppColors.textTertiary, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        opt.label,
                        style: AppTypography.label.copyWith(
                          color: isSelected ? opt.color : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '~${opt.grams.toInt()} g',
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? opt.color : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PortionOption {
  final String label;
  final double grams;
  final IconData icon;
  final Color color;
  const _PortionOption(this.label, this.grams, this.icon, this.color);
}
