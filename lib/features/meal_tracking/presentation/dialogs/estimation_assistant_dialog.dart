import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

/// Section 6 — Estimateur visuel basé sur des repères corporels familiers.
/// Zéro connaissance culinaire requise.
class EstimationAssistantDialog extends StatelessWidget {
  final String foodName;
  final void Function(double grams) onEstimated;

  const EstimationAssistantDialog({
    super.key,
    required this.foodName,
    required this.onEstimated,
  });

  static Future<void> show(
    BuildContext context, {
    required String foodName,
    required void Function(double grams) onEstimated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EstimationAssistantDialog(
        foodName: foodName,
        onEstimated: onEstimated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('Aide à l\'estimation', style: AppTypography.h3),
            const SizedBox(height: 6),
            Text(
              'À quoi ressemblait ta portion de $foodName ?',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            _EstimationOption(
              emoji: '🥄',
              title: 'Très petite',
              description: 'Comme une cuillère à soupe comble',
              grams: 20,
              onTap: () { Navigator.pop(context); onEstimated(20); },
            ),
            _EstimationOption(
              emoji: '🥚',
              title: 'Petite',
              description: 'Comme un œuf — creux de la main',
              grams: 60,
              onTap: () { Navigator.pop(context); onEstimated(60); },
            ),
            _EstimationOption(
              emoji: '✊',
              title: 'Moyenne',
              description: 'Comme mon poing fermé',
              grams: 130,
              onTap: () { Navigator.pop(context); onEstimated(130); },
            ),
            _EstimationOption(
              emoji: '🖐️',
              title: 'Grande',
              description: 'Comme ma paume ouverte',
              grams: 220,
              onTap: () { Navigator.pop(context); onEstimated(220); },
            ),
            _EstimationOption(
              emoji: '🍱',
              title: 'Très grande',
              description: 'Comme les deux paumes réunies',
              grams: 350,
              onTap: () { Navigator.pop(context); onEstimated(350); },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimationOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final double grams;
  final VoidCallback onTap;
  final bool isLast;

  const _EstimationOption({
    required this.emoji,
    required this.title,
    required this.description,
    required this.grams,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyMedium),
                      Text(description, style: AppTypography.caption),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '~${grams.toInt()} g',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
