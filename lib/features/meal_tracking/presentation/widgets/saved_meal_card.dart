import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/saved_meal.dart';

/// Section 7 — Carte d'un repas sauvegardé pour ajout rapide.
class SavedMealCard extends StatelessWidget {
  final SavedMeal meal;
  final VoidCallback onUse;
  final VoidCallback onDelete;

  const SavedMealCard({
    super.key,
    required this.meal,
    required this.onUse,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onUse,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(meal.icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name, style: AppTypography.bodyMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${meal.totalCalories.toInt()} kcal',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: AppTypography.caption),
                          const SizedBox(width: 8),
                          Text(
                            '${meal.items.length} aliment${meal.items.length > 1 ? 's' : ''}',
                            style: AppTypography.caption,
                          ),
                          if (meal.timesUsed > 0) ...[
                            const SizedBox(width: 8),
                            Text('•', style: AppTypography.caption),
                            const SizedBox(width: 8),
                            Text(
                              'utilisé ${meal.timesUsed}×',
                              style: AppTypography.caption,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ajouter',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textTertiary),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
