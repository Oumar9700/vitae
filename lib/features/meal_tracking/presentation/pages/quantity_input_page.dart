import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/datasources/portions_data_source.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/saved_meal.dart';
import '../bloc/meal_bloc.dart';
import '../dialogs/estimation_assistant_dialog.dart';
import '../widgets/common_portion_selector.dart';
import '../widgets/container_quantity_widget.dart';
import '../widgets/last_quantity_quick_select.dart';
import '../widgets/portion_selector_widget.dart';
import '../widgets/quantity_slider_widget.dart';
import '../widgets/saved_meal_card.dart';

/// Page de sélection de quantité — orchestre les 7 approches dans l'ordre
/// de priorité pour minimiser la charge mentale de l'utilisateur.
class QuantityInputPage extends StatefulWidget {
  final Food food;
  final String userId;
  final double? lastGrams;
  final DateTime? lastUsedDate;
  final List<SavedMeal> savedMeals;

  /// Rappelé quand l'utilisateur confirme une quantité.
  final void Function(double grams, String unit) onConfirm;

  /// Rappelé quand l'utilisateur choisit un repas sauvegardé complet.
  final void Function(SavedMeal meal)? onSavedMealUsed;

  const QuantityInputPage({
    super.key,
    required this.food,
    required this.userId,
    required this.onConfirm,
    this.lastGrams,
    this.lastUsedDate,
    this.savedMeals = const [],
    this.onSavedMealUsed,
  });

  @override
  State<QuantityInputPage> createState() => _QuantityInputPageState();
}

class _QuantityInputPageState extends State<QuantityInputPage> {
  double _selectedGrams = 100;
  String _selectedUnit = 'g';
  bool _showAdvanced = false;
  bool _historyDismissed = false;

  // Contrôleur du champ libre (saisie manuelle en fallback)
  final _manualCtrl = TextEditingController(text: '100');

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  void _confirm(double grams, [String? unit]) {
    widget.onConfirm(grams, unit ?? _selectedUnit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final portions = PortionsService.getPortions(widget.food.nom);
    final hasPreviousQuantity = widget.lastGrams != null &&
        widget.lastUsedDate != null &&
        !_historyDismissed;
    final relevantSavedMeals = widget.savedMeals
        .where((m) => m.items.any(
            (i) => i.foodId == widget.food.id || _normContains(i.foodName, widget.food.nom)))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text(
          widget.food.nom,
          style: AppTypography.h3,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Calories/100g en badge discret
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryPale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.food.caloriesPer100g.toInt()} kcal/100g',
              style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocListener<MealBloc, MealState>(
        listener: (_, state) {
          // Mise à jour de la liste des repas sauvegardés si rechargée
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre de section ────────────────────────────────────────────
              Text(
                'Combien en as-tu mangé ?',
                style: AppTypography.h2,
              ),
              const SizedBox(height: 4),
              Text(
                'Choisis la méthode qui te convient',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // ── PRIORITÉ 1 : Repas sauvegardés ──────────────────────────────
              if (relevantSavedMeals.isNotEmpty && widget.onSavedMealUsed != null) ...[
                _SectionHeader(icon: Icons.bookmark_rounded, title: 'Repas sauvegardés', color: AppColors.accent),
                const SizedBox(height: 8),
                ...relevantSavedMeals.map((m) => SavedMealCard(
                      meal: m,
                      onUse: () {
                        context.read<MealBloc>().add(MealSavedMealUsed(userId: widget.userId, mealId: m.id));
                        widget.onSavedMealUsed!(m);
                        Navigator.pop(context);
                      },
                      onDelete: () => context.read<MealBloc>().add(
                            MealSavedMealDeleted(userId: widget.userId, mealId: m.id),
                          ),
                    )),
                const SizedBox(height: 16),
              ],

              // ── PRIORITÉ 2 : Historique ──────────────────────────────────────
              if (hasPreviousQuantity) ...[
                _SectionHeader(icon: Icons.history_rounded, title: 'Dernière fois', color: AppColors.accent),
                const SizedBox(height: 8),
                LastQuantityQuickSelect(
                  foodName: widget.food.nom,
                  lastGrams: widget.lastGrams!,
                  lastUsedDate: widget.lastUsedDate!,
                  onSelected: (g) => _confirm(g, 'g'),
                  onCustom: () => setState(() => _historyDismissed = true),
                ),
                const SizedBox(height: 16),
              ],

              // ── PRIORITÉ 3 : Portions CIQUAL ────────────────────────────────
              if (portions.isNotEmpty) ...[
                _SectionHeader(icon: Icons.restaurant_menu_rounded, title: 'Portions courantes', color: AppColors.primary),
                const SizedBox(height: 8),
                PortionSelectorWidget(
                  portions: portions,
                  selectedGrams: _selectedGrams,
                  onSelected: (g) => setState(() => _selectedGrams = g),
                ),
                const SizedBox(height: 16),
              ],

              // ── PRIORITÉ 4 : Petit / Moyen / Grand ──────────────────────────
              _SectionHeader(icon: Icons.compare_arrows_rounded, title: 'Par taille', color: AppColors.primary),
              const SizedBox(height: 8),
              CommonPortionSelector(
                foodName: widget.food.nom,
                selectedGrams: _selectedGrams,
                onSelected: (g) => setState(() => _selectedGrams = g),
              ),
              const SizedBox(height: 16),

              // ── Bouton aide estimation ───────────────────────────────────────
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('Aide à l\'estimation visuelle'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => EstimationAssistantDialog.show(
                    context,
                    foodName: widget.food.nom,
                    onEstimated: (g) => setState(() => _selectedGrams = g),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── AVANCÉ : Slider + Récipients + Saisie libre ─────────────────
              _AdvancedSection(
                expanded: _showAdvanced,
                onToggle: () => setState(() => _showAdvanced = !_showAdvanced),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    QuantitySliderWidget(
                      food: widget.food,
                      initialGrams: _selectedGrams,
                      onChanged: (g) => setState(() => _selectedGrams = g),
                    ),
                    const SizedBox(height: 20),
                    ContainerQuantityWidget(
                      onChanged: (g) => setState(() => _selectedGrams = g),
                    ),
                    const SizedBox(height: 20),
                    _ManualEntry(
                      ctrl: _manualCtrl,
                      unit: _selectedUnit,
                      onUnitChanged: (u) => setState(() => _selectedUnit = u),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bouton de confirmation flottant ────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview nutrition
              _NutritionPreviewBar(food: widget.food, grams: _selectedGrams),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Confirmer — ${_selectedGrams.toInt()} g',
                icon: Icons.check_rounded,
                onPressed: () => _confirm(_selectedGrams),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _normContains(String a, String b) {
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[àâäéèêëîïôùûüç]'), '');
    return norm(a).contains(norm(b.split(',').first.trim())) ||
        norm(b).contains(norm(a.split(',').first.trim()));
  }
}

// ─── Widgets internes ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(title, style: AppTypography.label.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _AdvancedSection({
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Options avancées', style: AppTypography.label),
                  const Spacer(),
                  Icon(
                    expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _ManualEntry extends StatelessWidget {
  final TextEditingController ctrl;
  final String unit;
  final void Function(String) onUnitChanged;

  const _ManualEntry({required this.ctrl, required this.unit, required this.onUnitChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saisie libre', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                decoration: InputDecoration(
                  hintText: '100',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  filled: true,
                  fillColor: AppColors.bgWhite,
                ),
                style: AppTypography.body,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: unit,
                style: AppTypography.body,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  filled: true,
                  fillColor: AppColors.bgWhite,
                ),
                items: AppConstants.foodUnits
                    .map((u) => DropdownMenuItem(value: u, child: Text(u, style: AppTypography.body)))
                    .toList(),
                onChanged: (v) => onUnitChanged(v ?? 'g'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NutritionPreviewBar extends StatelessWidget {
  final Food food;
  final double grams;

  const _NutritionPreviewBar({required this.food, required this.grams});

  @override
  Widget build(BuildContext context) {
    final n = food.nutritionForQuantity(grams);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('${n.calories.toInt()}', 'kcal', AppColors.textPrimary),
          _VSep(),
          _Stat('${n.proteinG.toStringAsFixed(1)}g', 'Prot.', AppColors.chartProtein),
          _VSep(),
          _Stat('${n.carbsG.toStringAsFixed(1)}g', 'Gluc.', AppColors.chartCarbs),
          _VSep(),
          _Stat('${n.fatsG.toStringAsFixed(1)}g', 'Lip.', AppColors.chartFats),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.bodyMedium.copyWith(color: color)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: AppColors.primaryLight);
}
