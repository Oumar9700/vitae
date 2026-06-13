import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../di/injection_container.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../authentication/domain/entities/user_profile.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_repository.dart';

class AnalyticsPage extends StatefulWidget {
  final DailySummary today;
  final NutritionTargets targets;
  final String userId;
  final DateTime date;
  final UserProfile profile;

  const AnalyticsPage({
    super.key,
    required this.today,
    required this.targets,
    required this.userId,
    required this.date,
    required this.profile,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<DateTime, List<MealEntry>>? _weeklyData;
  bool _weeklyError = false;

  @override
  void initState() {
    super.initState();
    _loadWeekly();
  }

  Future<void> _loadWeekly() async {
    final result =
        await sl<MealRepository>().getWeeklyMeals(widget.userId, widget.date);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _weeklyError = true),
      (data) => setState(() => _weeklyData = data),
    );
  }

  List<_DayStats> get _weekStats {
    final days = <_DayStats>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(widget.date.year, widget.date.month, widget.date.day)
          .subtract(Duration(days: i));
      final entries = _weeklyData![day] ?? [];
      Nutrition total = Nutrition.zero;
      for (final e in entries) {
        total = total + e.nutrition;
      }
      final score = entries.isEmpty
          ? 0
          : NutritionCalculator.calculateDayScore(
              caloriesConsumed: total.calories,
              caloriesTarget: widget.targets.calories,
              proteinConsumed: total.proteinG,
              proteinTarget: widget.targets.proteinG,
              carbsConsumed: total.carbsG,
              carbsTarget: widget.targets.carbsG,
              fatsConsumed: total.fatsG,
              fatsTarget: widget.targets.fatsG,
              sugarConsumed: total.sugarG,
              sugarMax: widget.targets.sugarMax,
              sodiumConsumed: total.sodiumMg,
              sodiumMax: widget.targets.sodiumMax,
            );
      days.add(_DayStats(
        date: day,
        calories: total.calories,
        proteinG: total.proteinG,
        carbsG: total.carbsG,
        fatsG: total.fatsG,
        score: score,
        scoreLabel: entries.isEmpty
            ? '-'
            : NutritionCalculator.scoreLabel(score),
      ));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.today.totalNutrition;
    final targets = widget.targets;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        backgroundColor: AppColors.bgWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── SECTION 1: Aujourd'hui ──────────────────────────────────
            Text(
              "AUJOURD'HUI — ${widget.date.formattedFr.toUpperCase()}",
              style: AppTypography.h3,
            ),
            const SizedBox(height: 16),

            // Score badge
            _ScoreBadge(
                score: widget.today.score, label: widget.today.scoreLabel),
            const SizedBox(height: 16),

            // Macros donut chart card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Répartition des macros', style: AppTypography.label),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: _MacroDonutChart(
                      proteinG: total.proteinG,
                      carbsG: total.carbsG,
                      fatsG: total.fatsG,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MacroLegend(
                    proteinG: total.proteinG,
                    carbsG: total.carbsG,
                    fatsG: total.fatsG,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nutrient detail rows
            _card(
              child: Column(
                children: [
                  _DetailRow('Calories', total.calories, targets.calories,
                      'kcal',
                      isCalorie: true),
                  _DetailRow(
                      'Protéines', total.proteinG, targets.proteinG, 'g'),
                  _DetailRow('Glucides', total.carbsG, targets.carbsG, 'g'),
                  _DetailRow('Lipides', total.fatsG, targets.fatsG, 'g'),
                  _DetailRow(
                      'Fibres', total.fiberG, targets.fiberMin, 'g',
                      isMin: true),
                  _DetailRow(
                      'Sucres', total.sugarG, targets.sugarMax, 'g',
                      isMax: true),
                  _DetailRow(
                      'Sodium', total.sodiumMg, targets.sodiumMax, 'mg',
                      isMax: true),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── SECTION 2: 7 derniers jours ────────────────────────────
            const Text('7 DERNIERS JOURS', style: AppTypography.h3),
            const SizedBox(height: 16),

            if (_weeklyData == null && !_weeklyError)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_weeklyError)
              _card(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Impossible de charger les données hebdomadaires.',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else ...[
              // Calories chart
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calories · 7 jours', style: AppTypography.label),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _CaloriesBarChart(
                        stats: _weekStats,
                        caloriesTarget: widget.targets.calories,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Score chart
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score · 7 jours', style: AppTypography.label),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: _ScoreBarChart(stats: _weekStats),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // ─── SECTION 3: Conseils ─────────────────────────────────────
            _PageAdviceSection(
                summary: widget.today, targets: widget.targets),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day stats model
// ─────────────────────────────────────────────────────────────────────────────

class _DayStats {
  final DateTime date;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final int score;
  final String scoreLabel;

  const _DayStats({
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.score,
    required this.scoreLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Macros donut chart
// ─────────────────────────────────────────────────────────────────────────────

class _MacroDonutChart extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatsG;

  const _MacroDonutChart({
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  @override
  Widget build(BuildContext context) {
    final proteinKcal = proteinG * 4;
    final carbsKcal = carbsG * 4;
    final fatsKcal = fatsG * 9;
    final totalKcal = proteinKcal + carbsKcal + fatsKcal;

    List<PieChartSectionData> sections;

    if (totalKcal == 0) {
      sections = [
        PieChartSectionData(
          color: AppColors.border,
          value: 1,
          showTitle: false,
          radius: 40,
        ),
      ];
    } else {
      sections = [
        PieChartSectionData(
          color: AppColors.chartProtein,
          value: proteinKcal,
          showTitle: false,
          radius: 40,
        ),
        PieChartSectionData(
          color: AppColors.chartCarbs,
          value: carbsKcal,
          showTitle: false,
          radius: 40,
        ),
        PieChartSectionData(
          color: AppColors.chartFats,
          value: fatsKcal,
          showTitle: false,
          radius: 40,
        ),
      ];
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 48,
        sectionsSpace: 3,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Macro legend
// ─────────────────────────────────────────────────────────────────────────────

class _MacroLegend extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatsG;

  const _MacroLegend({
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  @override
  Widget build(BuildContext context) {
    final proteinKcal = proteinG * 4;
    final carbsKcal = carbsG * 4;
    final fatsKcal = fatsG * 9;
    final totalKcal = proteinKcal + carbsKcal + fatsKcal;

    String pct(double kcal) {
      if (totalKcal == 0) return '0%';
      return '${(kcal / totalKcal * 100).round()}%';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(
          color: AppColors.chartProtein,
          label: 'Protéines',
          percentage: pct(proteinKcal),
          grams: proteinG,
        ),
        _LegendItem(
          color: AppColors.chartCarbs,
          label: 'Glucides',
          percentage: pct(carbsKcal),
          grams: carbsG,
        ),
        _LegendItem(
          color: AppColors.chartFats,
          label: 'Lipides',
          percentage: pct(fatsKcal),
          grams: fatsG,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;
  final double grams;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.grams,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$percentage · ${grams.toStringAsFixed(1)}g',
          style: AppTypography.caption
              .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score badge (reused from analytics_panel style)
// ─────────────────────────────────────────────────────────────────────────────

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
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(label,
                  style: AppTypography.h1
                      .copyWith(color: Colors.white, fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score >= 90
                      ? 'Excellent!'
                      : score >= 80
                          ? 'Bon équilibre'
                          : score >= 70
                              ? 'À améliorer'
                              : 'Attention',
                  style: AppTypography.h3,
                ),
                Text('$score / 100 points',
                    style: AppTypography.label
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail row (reused from analytics_panel)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final bool isMin;
  final bool isMax;
  final bool isCalorie;

  const _DetailRow(this.label, this.consumed, this.target, this.unit,
      {this.isMin = false, this.isMax = false, this.isCalorie = false});

  String get _statusIcon {
    if (isMax) {
      return consumed <= target
          ? '✅'
          : consumed <= target * 1.2
              ? '⚠️'
              : '❌';
    }
    if (isMin) {
      return consumed >= target
          ? '✅'
          : consumed >= target * 0.7
              ? '⚠️'
              : '❌';
    }
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
              color: _statusIcon == '❌'
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
          Text(' / ${_fmt(target)}$unit', style: AppTypography.label),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (unit == 'mg') return v.toInt().toString();
    return v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calories bar chart (7 days)
// ─────────────────────────────────────────────────────────────────────────────

class _CaloriesBarChart extends StatelessWidget {
  final List<_DayStats> stats;
  final double caloriesTarget;

  const _CaloriesBarChart(
      {required this.stats, required this.caloriesTarget});

  static const List<String> _dayLabels = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  String _dayLabel(DateTime d) => _dayLabels[d.weekday - 1];

  @override
  Widget build(BuildContext context) {
    final maxVal = stats.fold(caloriesTarget,
            (m, s) => s.calories > m ? s.calories : m) *
        1.1;

    final today = DateTime.now();
    final todayNorm =
        DateTime(today.year, today.month, today.day);

    final bars = stats.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final isToday = s.date == todayNorm;
      final color = s.calories <= caloriesTarget * 1.1
          ? AppColors.primary
          : AppColors.error;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: s.calories == 0 ? 0.0 : s.calories,
            color: isToday ? color : color.withValues(alpha: 0.7),
            width: 20,
            borderRadius: BorderRadius.circular(4),
            borderSide: isToday
                ? const BorderSide(color: AppColors.textPrimary, width: 1.5)
                : BorderSide.none,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxVal,
        barGroups: bars,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: caloriesTarget,
              color: AppColors.accent,
              strokeWidth: 1.5,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => 'objectif',
                style: AppTypography.caption
                    .copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: (maxVal / 3).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _dayLabel(stats[i].date),
                    style: AppTypography.caption,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} kcal',
                AppTypography.caption
                    .copyWith(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Score bar chart (7 days)
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreBarChart extends StatelessWidget {
  final List<_DayStats> stats;

  const _ScoreBarChart({required this.stats});

  static const List<String> _dayLabels = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  String _dayLabel(DateTime d) => _dayLabels[d.weekday - 1];

  Color _barColor(int score) {
    if (score >= 90) return AppColors.primary;
    if (score >= 80) return AppColors.accent;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final bars = stats.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final hasData = s.score > 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: hasData ? s.score.toDouble() : 2.0,
            color: _barColor(s.score),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        barGroups: bars,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 50,
              getTitlesWidget: (value, meta) {
                if (value != 0 && value != 50 && value != 100) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: AppTypography.caption,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _dayLabel(stats[i].date),
                    style: AppTypography.caption,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final s = stats[group.x];
              if (s.score == 0) return null;
              return BarTooltipItem(
                '${s.scoreLabel} · ${s.score}pts',
                AppTypography.caption
                    .copyWith(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advice section (inline copy of analytics_panel's _AdviceSection)
// ─────────────────────────────────────────────────────────────────────────────

class _PageAdviceSection extends StatelessWidget {
  final DailySummary summary;
  final NutritionTargets targets;

  const _PageAdviceSection({required this.summary, required this.targets});

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
        Text('CONSEILS', style: AppTypography.h3),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryPale,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _advices
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(a, style: AppTypography.body),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
