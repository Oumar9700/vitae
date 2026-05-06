import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/meal_entry.dart';

class MealSectionWidget extends StatelessWidget {
  final String mealType;
  final List<MealEntry> entries;
  final void Function(MealEntry) onEdit;
  final void Function(MealEntry) onDelete;

  const MealSectionWidget({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final totalCals = entries.fold(0.0, (sum, e) => sum + e.nutrition.calories);
    final label = AppConstants.mealTypeLabels[mealType] ?? mealType;
    final emoji = AppConstants.mealTypeEmojis[mealType] ?? '🍽️';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text('$emoji  $label', style: AppTypography.h3.copyWith(fontSize: 15)),
              const Spacer(),
              Text('${totalCals.toInt()} kcal', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        ...entries.map((entry) => MealEntryCard(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => onDelete(entry),
            )),
        const Divider(height: 24),
      ],
    );
  }
}

class MealEntryCard extends StatelessWidget {
  final MealEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MealEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Supprimer?', style: AppTypography.h3),
            content: Text('Supprimer "${entry.foodName}" de ton journal?', style: AppTypography.body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.foodName,
                    style: AppTypography.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatQty(entry.quantity)} ${entry.unit}  •  ${_macroSummary(entry)}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.nutrition.calories.toInt()} kcal',
              style: AppTypography.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  String _formatQty(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  String _macroSummary(MealEntry e) {
    return 'P:${e.nutrition.proteinG.toStringAsFixed(0)}g  G:${e.nutrition.carbsG.toStringAsFixed(0)}g  L:${e.nutrition.fatsG.toStringAsFixed(0)}g';
  }
}
