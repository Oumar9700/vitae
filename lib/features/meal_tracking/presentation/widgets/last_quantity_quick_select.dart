import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

/// Section 5 — "Même quantité qu'avant ?" basé sur l'historique local.
class LastQuantityQuickSelect extends StatelessWidget {
  final String foodName;
  final double lastGrams;
  final DateTime lastUsedDate;
  final void Function(double grams) onSelected;
  final VoidCallback onCustom;

  const LastQuantityQuickSelect({
    super.key,
    required this.foodName,
    required this.lastGrams,
    required this.lastUsedDate,
    required this.onSelected,
    required this.onCustom,
  });

  String get _timeLabel {
    final diff = DateTime.now().difference(lastUsedDate).inDays;
    if (diff == 0) return "aujourd'hui";
    if (diff == 1) return 'hier';
    if (diff < 7) return 'il y a $diff jours';
    return 'il y a ${diff ~/ 7} semaine${diff >= 14 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Même quantité que $_timeLabel ?',
                  style: AppTypography.label.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onSelected(lastGrams),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    '${lastGrams.toInt()} g — Oui',
                    style: AppTypography.label.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCustom,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    'Autre quantité',
                    style: AppTypography.label.copyWith(color: AppColors.accentDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
