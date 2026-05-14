import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Reusable meal-type chip selector.
/// Used in ManualInputPage, EditMealPage, BatchMealInputPage.
class MealTypeSelectorWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const MealTypeSelectorWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Repas', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.mealTypes.map((type) {
            final label    = AppConstants.mealTypeLabels[type] ?? type;
            final emoji    = AppConstants.mealTypeEmojis[type] ?? '';
            final isActive = selected == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color:        isActive ? AppColors.primaryPale : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Text(
                  '$emoji $label',
                  style: AppTypography.label.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
