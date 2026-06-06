import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../di/injection_container.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/meal_type_selector_widget.dart';
import '../../../meal_tracking/domain/entities/food.dart';
import '../../../meal_tracking/domain/entities/meal_entry.dart';
import '../../../meal_tracking/domain/entities/saved_meal.dart';
import '../../../meal_tracking/domain/repositories/meal_repository.dart';
import '../../../meal_tracking/presentation/bloc/meal_bloc.dart';
import '../../../meal_tracking/presentation/pages/quantity_input_page.dart';

/// Page de confirmation après scan d'un code-barres.
/// Affiche la fiche produit, laisse choisir le type de repas,
/// puis délègue la sélection de quantité à [QuantityInputPage].
/// Pop avec `true` si le repas a été ajouté, `false` sinon.
class BarcodeProductConfirmationPage extends StatefulWidget {
  final Food food;
  final String userId;
  final DateTime date;

  const BarcodeProductConfirmationPage({
    super.key,
    required this.food,
    required this.userId,
    required this.date,
  });

  @override
  State<BarcodeProductConfirmationPage> createState() =>
      _BarcodeProductConfirmationPageState();
}

class _BarcodeProductConfirmationPageState
    extends State<BarcodeProductConfirmationPage> {
  String _mealType = 'dejeuner';
  double? _selectedGrams;
  String _selectedUnit = 'g';
  double? _lastGrams;
  DateTime? _lastUsedDate;
  List<SavedMeal> _savedMeals = [];
  SavedMeal? _pendingSavedMeal;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    context.read<MealBloc>().add(MealSavedMealsRequested(widget.userId));
  }

  Future<void> _loadHistory() async {
    final (g, d) =
        await sl<MealRepository>().getFoodHistory(widget.userId, widget.food.id);
    if (mounted) setState(() { _lastGrams = g; _lastUsedDate = d; });
  }

  Future<void> _openQuantitySelector() async {
    double? confirmedGrams;
    String? confirmedUnit;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (newCtx) => BlocProvider.value(
          value: context.read<MealBloc>(),
          child: QuantityInputPage(
            food: widget.food,
            userId: widget.userId,
            lastGrams: _lastGrams,
            lastUsedDate: _lastUsedDate,
            savedMeals: _savedMeals,
            onConfirm: (g, u) {
              confirmedGrams = g;
              confirmedUnit = u;
            },
            onSavedMealUsed: (meal) => _pendingSavedMeal = meal,
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (_pendingSavedMeal != null) {
      final meal = _pendingSavedMeal!;
      _pendingSavedMeal = null;
      _addSavedMeal(meal);
      return;
    }

    if (confirmedGrams != null) {
      setState(() {
        _selectedGrams = confirmedGrams;
        _selectedUnit = confirmedUnit ?? 'g';
      });
    }
  }

  void _addSavedMeal(SavedMeal meal) {
    final now = DateTime.now();
    for (final item in meal.items) {
      final perHundred = item.grams > 0 ? (100 / item.grams) : 1.0;
      final reconstructed = Food(
        id: item.foodId,
        nom: item.foodName,
        caloriesPer100g: item.nutrition.calories * perHundred,
        proteinPer100g: item.nutrition.proteinG * perHundred,
        carbsPer100g: item.nutrition.carbsG * perHundred,
        fatsPer100g: item.nutrition.fatsG * perHundred,
        fiberPer100g: item.nutrition.fiberG * perHundred,
        sugarPer100g: item.nutrition.sugarG * perHundred,
        sodiumPer100g: item.nutrition.sodiumMg * perHundred,
        source: 'saved',
      );
      final entry = MealEntry(
        id: const Uuid().v4(),
        userId: widget.userId,
        date: widget.date,
        mealType: _mealType,
        foodName: item.foodName,
        quantity: item.grams,
        unit: 'g',
        nutrition: item.nutrition,
        source: 'repas_sauvegarde',
        foodId: item.foodId,
        createdAt: now,
        updatedAt: now,
      );
      context.read<MealBloc>().add(MealAddRequested(entry: entry, food: reconstructed));
    }
    Navigator.pop(context, true);
  }

  void _confirm() {
    if (_selectedGrams == null) return;
    final grams = _selectedGrams!;
    final now = DateTime.now();
    final entry = MealEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      date: widget.date,
      mealType: _mealType,
      foodName: widget.food.nom,
      quantity: grams,
      unit: _selectedUnit,
      nutrition: widget.food.nutritionForQuantity(grams),
      source: 'code_barre',
      foodId: widget.food.id,
      createdAt: now,
      updatedAt: now,
    );
    context.read<MealBloc>().add(MealAddRequested(entry: entry, food: widget.food));
    sl<MealRepository>().saveFoodHistory(widget.userId, widget.food.id, grams);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealBloc, MealState>(
      listener: (_, state) {
        if (state is MealSavedMealsLoaded) {
          setState(() => _savedMeals = state.savedMeals);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgWhite,
        appBar: AppBar(
          title: Text('Produit trouvé', style: AppTypography.h3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Fiche produit ──────────────────────────────────────────────
              _ProductCard(food: widget.food),
              const SizedBox(height: 24),

              // ── Type de repas ──────────────────────────────────────────────
              MealTypeSelectorWidget(
                selected: _mealType,
                onChanged: (t) => setState(() => _mealType = t),
              ),
              const SizedBox(height: 24),

              // ── Quantité ───────────────────────────────────────────────────
              Text('Quantité', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),

              if (_selectedGrams != null) ...[
                // Quantité déjà sélectionnée
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedGrams!.toInt()} $_selectedUnit',
                              style: AppTypography.h3.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              '${widget.food.nutritionForQuantity(_selectedGrams!).calories.toInt()} kcal',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _openQuantitySelector,
                        child: const Text('Modifier'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Pas encore sélectionné
                OutlinedButton.icon(
                  onPressed: _openQuantitySelector,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Sélectionner la quantité'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: PrimaryButton(
              label: _selectedGrams != null
                  ? 'Ajouter au journal'
                  : 'Sélectionne une quantité',
              icon: Icons.check_rounded,
              onPressed: _selectedGrams != null ? _confirm : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Fiche produit ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Food food;
  const _ProductCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image produit
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: food.imageUrl != null
                ? Image.network(
                    food.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _FoodIcon(),
                  )
                : _FoodIcon(),
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.nom,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (food.brand != null && food.brand!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(food.brand!, style: AppTypography.caption),
                ],
                const SizedBox(height: 8),
                // Macros/100g
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _MacroBadge('${food.caloriesPer100g.toInt()} kcal', AppColors.textPrimary),
                    _MacroBadge('P: ${food.proteinPer100g.toStringAsFixed(1)}g', AppColors.chartProtein),
                    _MacroBadge('G: ${food.carbsPer100g.toStringAsFixed(1)}g', AppColors.chartCarbs),
                    _MacroBadge('L: ${food.fatsPer100g.toStringAsFixed(1)}g', AppColors.chartFats),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 32),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _MacroBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: AppTypography.caption
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
