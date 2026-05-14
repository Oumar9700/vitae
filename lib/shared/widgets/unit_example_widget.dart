import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Inline hint showing a concrete example for each unit.
/// Place below the unit dropdown to help users understand conversions.
class UnitExampleWidget extends StatelessWidget {
  final String unit;

  const UnitExampleWidget({super.key, required this.unit});

  static const Map<String, String> _examples = {
    'g':                  'Ex: 150 g de poulet = 1 filet moyen',
    'ml':                 'Ex: 250 ml de lait = 1 verre',
    'tranche':            'Ex: 1 tranche de pain ≈ 28 g',
    'portion':            'Ex: 1 portion de pâtes ≈ 150 g (cru)',
    'bol':                'Ex: 1 bol de céréales ≈ 250 g',
    'verre':              'Ex: 1 verre d\'eau / jus ≈ 200 ml',
    'tasse':              'Ex: 1 tasse de café ≈ 240 ml',
    'cuillère à soupe':   'Ex: 1 c. à soupe d\'huile ≈ 15 ml',
    'cuillère à café':    'Ex: 1 c. à café de sucre ≈ 5 g',
  };

  @override
  Widget build(BuildContext context) {
    final example = _examples[unit];
    final grams   = AppConstants.unitToGrams[unit];
    if (example == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.unit, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  example,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (grams != null && unit != 'g' && unit != 'ml')
                  Text(
                    '1 $unit = ${grams.toStringAsFixed(0)} g',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
