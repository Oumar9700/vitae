import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Expandable info card explaining BMR, TDEE and how nutrition targets are calculated.
class NutritionInfoWidget extends StatefulWidget {
  const NutritionInfoWidget({super.key});

  @override
  State<NutritionInfoWidget> createState() => _NutritionInfoWidgetState();
}

class _NutritionInfoWidgetState extends State<NutritionInfoWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentLight),
      ),
      child: Column(
        children: [
          // Header — always visible
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(AppIcons.info, size: 20, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Comment sont calculés tes besoins ?',
                      style: AppTypography.label.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.expand_more_rounded,
                        color: AppColors.accent, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          SizeTransition(
            sizeFactor: _expandAnim,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: AppColors.accentLight),
                  SizedBox(height: 12),
                  _InfoBlock(
                    title: 'BMR — Métabolisme de base',
                    body:
                        'C\'est le nombre de calories que ton corps brûle au repos pour maintenir ses fonctions vitales (respiration, circulation, température). '
                        'Calculé avec la formule Mifflin-St Jeor, reconnue comme la plus précise pour la majorité des adultes.',
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  _InfoBlock(
                    title: 'TDEE — Dépense journalière totale',
                    body:
                        'C\'est ton BMR multiplié par un facteur d\'activité (1,2 → sédentaire · 1,9 → très actif). '
                        'C\'est le nombre de calories que tu dois consommer pour maintenir ton poids actuel.',
                    color: AppColors.accent,
                  ),
                  SizedBox(height: 12),
                  _InfoBlock(
                    title: 'Objectif calorique',
                    body:
                        'Si ton objectif est la perte de poids, on soustrait ~500 kcal/jour au TDEE (soit -0,5 kg/semaine). '
                        'Pour la prise de masse, on ajoute ~300 kcal. Pour le maintien, TDEE = objectif.',
                    color: AppColors.chartFiber,
                  ),
                  SizedBox(height: 12),
                  _InfoBlock(
                    title: 'Macros recommandées',
                    body:
                        'Protéines : 1,6–2 g/kg de poids corporel · Lipides : 25–35 % des calories · '
                        'Glucides : le reste. Ces valeurs suivent les recommandations de l\'ANSES 2021.',
                    color: AppColors.chartCarbs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;
  final Color color;

  const _InfoBlock({
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          margin: const EdgeInsets.only(top: 2, right: 12),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
