import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../data/datasources/portions_data_source.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_portion.dart';
import '../dialogs/estimation_assistant_dialog.dart';

/// Sélecteur de quantité compact pour le mode batch.
/// Pas de navigation modale — tout inline dans la row.
///
/// Priorité d'affichage :
///   1. Historique quick-chip (si dispo)
///   2. Chips CIQUAL OU boutons S/M/L (exclusif)
///   3. Saisie libre + unité + aide estimation
class BatchQuantitySelectorWidget extends StatefulWidget {
  final Food food;
  final double initialQuantity;
  final String initialUnit;
  final double? lastQuantityUsed;
  final DateTime? lastUsedDate;
  final void Function(double quantity, String unit) onChanged;

  const BatchQuantitySelectorWidget({
    super.key,
    required this.food,
    required this.initialQuantity,
    required this.initialUnit,
    this.lastQuantityUsed,
    this.lastUsedDate,
    required this.onChanged,
  });

  @override
  State<BatchQuantitySelectorWidget> createState() =>
      _BatchQuantitySelectorWidgetState();
}

class _BatchQuantitySelectorWidgetState
    extends State<BatchQuantitySelectorWidget> {
  late double _quantity;
  late String _unit;
  final _manualCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _unit = widget.initialUnit;
    _manualCtrl.text = widget.initialQuantity.toInt().toString();
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  void _select(double grams, String unit) {
    setState(() {
      _quantity = grams;
      _unit = unit;
      _manualCtrl.text = grams.toInt().toString();
    });
    widget.onChanged(grams, unit);
  }

  @override
  Widget build(BuildContext context) {
    final portions = PortionsService.getPortions(widget.food.nom);
    final sizes = PortionsService.getCommonSizes(widget.food.nom);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),

        // ── 1. Historique ─────────────────────────────────────────────────────
        if (widget.lastQuantityUsed != null && widget.lastUsedDate != null) ...[
          _HistoryChip(
            grams: widget.lastQuantityUsed!,
            date: widget.lastUsedDate!,
            onTap: () => _select(widget.lastQuantityUsed!, 'g'),
          ),
          const SizedBox(height: 8),
        ],

        // ── 2. Portions CIQUAL ou S/M/L ──────────────────────────────────────
        if (portions.isNotEmpty) ...[
          _CiqualChips(
            portions: portions,
            selectedGrams: _quantity,
            onSelected: (p) => _select(p.grams, 'g'),
          ),
          const SizedBox(height: 8),
        ] else ...[
          _VisualSizeRow(
            sizes: sizes,
            onSelected: (g) => _select(g, 'g'),
          ),
          const SizedBox(height: 8),
        ],

        // ── 3. Saisie libre + unité + aide ───────────────────────────────────
        Row(
          children: [
            SizedBox(
              width: 72,
              child: TextField(
                controller: _manualCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                textAlign: TextAlign.center,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Qté',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  filled: true,
                  fillColor: AppColors.bgWhite,
                ),
                onChanged: (v) {
                  final q = double.tryParse(v.replaceAll(',', '.')) ?? _quantity;
                  setState(() => _quantity = q);
                  widget.onChanged(q, _unit);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _unit,
                style: AppTypography.body,
                isDense: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  filled: true,
                  fillColor: AppColors.bgWhite,
                ),
                items: AppConstants.foodUnits
                    .map((u) =>
                        DropdownMenuItem(value: u, child: Text(u, style: AppTypography.body)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _unit = v);
                  widget.onChanged(_quantity, v);
                },
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                icon: const Icon(Icons.help_outline_rounded,
                    size: 18, color: AppColors.primary),
                padding: EdgeInsets.zero,
                tooltip: "Aide à l'estimation",
                onPressed: () => EstimationAssistantDialog.show(
                  context,
                  foodName: widget.food.nom,
                  onEstimated: (g) => _select(g, 'g'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Historique quick-chip ──────────────────────────────────────────────────

class _HistoryChip extends StatelessWidget {
  final double grams;
  final DateTime date;
  final VoidCallback onTap;

  const _HistoryChip(
      {required this.grams, required this.date, required this.onTap});

  String get _timeLabel {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return "aujourd'hui";
    if (diff == 1) return 'hier';
    if (diff < 7) return 'il y a ${diff}j';
    return 'il y a ${diff ~/ 7}sem';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentPale,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accentLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.history, size: 13, color: AppColors.accentDark),
            const SizedBox(width: 6),
            Text(
              'Même que $_timeLabel — ${grams.toInt()} g',
              style: AppTypography.caption.copyWith(
                color: AppColors.accentDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chips CIQUAL ──────────────────────────────────────────────────────────

class _CiqualChips extends StatelessWidget {
  final List<FoodPortion> portions;
  final double selectedGrams;
  final void Function(FoodPortion) onSelected;

  const _CiqualChips(
      {required this.portions,
      required this.selectedGrams,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: portions.map((p) {
        final active = (p.grams - selectedGrams).abs() < 1;
        return GestureDetector(
          onTap: () => onSelected(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryPale : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              '${p.label} · ${p.grams.toInt()}g',
              style: AppTypography.caption.copyWith(
                color: active ? AppColors.primary : AppColors.textPrimary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Boutons S/M/L ─────────────────────────────────────────────────────────

class _VisualSizeRow extends StatelessWidget {
  final PortionSizes sizes;
  final void Function(double) onSelected;

  const _VisualSizeRow({required this.sizes, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SizeBtn(
            emoji: '🤏',
            label: 'Petit',
            grams: sizes.small,
            onTap: () => onSelected(sizes.small)),
        const SizedBox(width: 6),
        _SizeBtn(
            emoji: '✊',
            label: 'Moyen',
            grams: sizes.medium,
            onTap: () => onSelected(sizes.medium)),
        const SizedBox(width: 6),
        _SizeBtn(
            emoji: '🖐️',
            label: 'Grand',
            grams: sizes.large,
            onTap: () => onSelected(sizes.large)),
      ],
    );
  }
}

class _SizeBtn extends StatelessWidget {
  final String emoji;
  final String label;
  final double grams;
  final VoidCallback onTap;

  const _SizeBtn(
      {required this.emoji,
      required this.label,
      required this.grams,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(label,
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w600)),
              Text('~${grams.toInt()}g',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
