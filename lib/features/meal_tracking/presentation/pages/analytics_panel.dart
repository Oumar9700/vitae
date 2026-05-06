import 'package:flutter/material.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../domain/entities/meal_entry.dart';

class AnalyticsPanel extends StatelessWidget {
  final DailySummary summary;
  final NutritionTargets targets;

  const AnalyticsPanel({super.key, required this.summary, required this.targets});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalNutrition;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('Détails nutritionnels', style: AppTypography.h2),
            const SizedBox(height: 4),
            Text('Score du jour', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Score Badge
            _ScoreBadge(score: summary.score, label: summary.scoreLabel),
            const SizedBox(height: 24),

            // Detailed breakdown
            _DetailRow('Calories', total.calories, targets.calories, 'kcal', isCalorie: true),
            _DetailRow('Protéines', total.proteinG, targets.proteinG, 'g'),
            _DetailRow('Glucides', total.carbsG, targets.carbsG, 'g'),
            _DetailRow('Lipides', total.fatsG, targets.fatsG, 'g'),
            _DetailRow('Fibres', total.fiberG, targets.fiberMin, 'g', isMin: true),
            _DetailRow('Sucres', total.sugarG, targets.sugarMax, 'g', isMax: true),
            _DetailRow('Sodium', total.sodiumMg, targets.sodiumMax, 'mg', isMax: true),
            const SizedBox(height: 24),

            // Advice
            _AdviceSection(summary: summary, targets: targets),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final String label;

  const _ScoreBadge({required this.score, required this.label});

  Color get _color {
    if (score >= 90) return AppColors.primary;
    if (score >= 80) return AppColors.accent;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(label, style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score >= 90 ? 'Excellent!' : score >= 80 ? 'Bon équilibre' : score >= 70 ? 'À améliorer' : 'Attention',
                  style: AppTypography.h3,
                ),
                Text('$score / 100 points', style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final bool isMin;
  final bool isMax;
  final bool isCalorie;

  const _DetailRow(this.label, this.consumed, this.target, this.unit, {
    this.isMin = false,
    this.isMax = false,
    this.isCalorie = false,
  });

  String get _statusIcon {
    if (isMax) return consumed <= target ? '✅' : consumed <= target * 1.2 ? '⚠️' : '❌';
    if (isMin) return consumed >= target ? '✅' : consumed >= target * 0.7 ? '⚠️' : '❌';
    final ratio = consumed / target;
    if (ratio >= 0.8 && ratio <= 1.2) return '✅';
    if (ratio >= 0.6 && ratio <= 1.4) return '⚠️';
    return '❌';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(_statusIcon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(
            '${_fmt(consumed)}$unit',
            style: AppTypography.bodyMedium.copyWith(
              color: _statusIcon == '❌' ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          Text(
            ' / ${_fmt(target)}$unit',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (unit == 'mg') return v.toInt().toString();
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }
}

class _AdviceSection extends StatelessWidget {
  final DailySummary summary;
  final NutritionTargets targets;

  const _AdviceSection({required this.summary, required this.targets});

  List<String> get _advices {
    final total = summary.totalNutrition;
    final advices = <String>[];

    if (total.proteinG < targets.proteinG * 0.8) {
      advices.add('💪 Ajoute des protéines: poulet, œufs, lentilles, tofu');
    }
    if (total.fiberG < targets.fiberMin * 0.7) {
      advices.add('🥦 Fibres insuffisantes: essaie brocoli, riz complet, pommes');
    }
    if (total.sugarG > targets.sugarMax) {
      advices.add('🍬 Sucres élevés: réduis les boissons sucrées et desserts');
    }
    if (total.sodiumMg > targets.sodiumMax) {
      advices.add('🧂 Sodium élevé: limite sauces et produits transformés');
    }
    if (total.calories < targets.calories * 0.6 && summary.allEntries.isNotEmpty) {
      advices.add('⚡ Déficit trop important: mange 200 kcal de plus');
    }
    if (total.calories > targets.calories * 1.2) {
      advices.add('⚖️ Calories dépassées: sois plus léger(e) demain');
    }
    if (advices.isEmpty) {
      advices.add('🌟 Excellent équilibre nutritionnel aujourd\'hui! Continue!');
    }
    return advices;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conseils personnalisés', style: AppTypography.h3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryPale,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _advices.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(a, style: AppTypography.body),
                )).toList(),
          ),
        ),
      ],
    );
  }
}
