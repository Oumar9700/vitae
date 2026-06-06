import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../di/injection_container.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/meal_type_selector_widget.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/entities/saved_meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../bloc/meal_bloc.dart';
import 'quantity_input_page.dart';

class ManualInputPage extends StatefulWidget {
  final String userId;
  final DateTime date;

  const ManualInputPage({super.key, required this.userId, required this.date});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final _searchCtrl = TextEditingController();

  Food? _selectedFood;
  String _selectedMealType = 'dejeuner';
  Timer? _debounceTimer;
  List<Food> _searchResults = [];
  bool _isSearching = false;
  bool _searchError = false;
  bool _loadingHistory = false;

  List<SavedMeal> _savedMeals = [];
  // Repas sauvegardé sélectionné dans QuantityInputPage — traité après le pop
  SavedMeal? _pendingSavedMeal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealBloc>().add(MealSavedMealsRequested(widget.userId));
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _searchError = false;
      });
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: 800),
      () => _triggerSearch(query.trim()),
    );
  }

  void _triggerSearch(String query) {
    final q = query.trim();
    if (q.length < 3) return;
    _debounceTimer?.cancel();
    context.read<MealBloc>().add(MealFoodSearched(q));
    setState(() {
      _isSearching = true;
      _searchError = false;
    });
  }

  Future<void> _selectFood(Food food) async {
    setState(() {
      _selectedFood = food;
      _searchCtrl.text = food.nom;
      _searchResults = [];
      _isSearching = false;
      _loadingHistory = true;
    });
    FocusScope.of(context).unfocus();

    final (lastGrams, lastUsedDate) =
        await sl<MealRepository>().getFoodHistory(widget.userId, food.id);

    if (!mounted) return;
    setState(() => _loadingHistory = false);

    double? confirmedGrams;
    String? confirmedUnit;

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (newCtx) => BlocProvider.value(
          value: context.read<MealBloc>(),
          child: QuantityInputPage(
            food: food,
            userId: widget.userId,
            lastGrams: lastGrams,
            lastUsedDate: lastUsedDate,
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
      _handleSavedMealUsed(meal);
      return;
    }

    if (confirmedGrams != null) {
      _onQuantityConfirmed(food, confirmedGrams!, confirmedUnit ?? 'g');
    }
    // Si pas de confirmation → l'utilisateur a annulé, on reste sur la page
  }

  void _onQuantityConfirmed(Food food, double grams, String unit) {
    final now = DateTime.now();
    final entry = MealEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      date: widget.date,
      mealType: _selectedMealType,
      foodName: food.nom,
      quantity: grams,
      unit: unit,
      nutrition: food.nutritionForQuantity(grams),
      source: 'manuel',
      foodId: food.id,
      createdAt: now,
      updatedAt: now,
    );
    context.read<MealBloc>().add(MealAddRequested(entry: entry, food: food));
    sl<MealRepository>().saveFoodHistory(widget.userId, food.id, grams);
    Navigator.pop(context);
  }

  void _handleSavedMealUsed(SavedMeal meal) {
    final now = DateTime.now();
    for (final item in meal.items) {
      final perHundred = item.grams > 0 ? (100 / item.grams) : 1.0;
      final reconstructedFood = Food(
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
        mealType: _selectedMealType,
        foodName: item.foodName,
        quantity: item.grams,
        unit: 'g',
        nutrition: item.nutrition,
        source: 'repas_sauvegarde',
        foodId: item.foodId,
        createdAt: now,
        updatedAt: now,
      );
      context.read<MealBloc>().add(MealAddRequested(entry: entry, food: reconstructedFood));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Ajouter un aliment', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<MealBloc, MealState>(
        listener: (context, state) {
          if (state is MealFoodSearchResults) {
            setState(() {
              _searchResults = state.foods;
              _isSearching = false;
              _searchError = false;
            });
          }
          if (state is MealSavedMealsLoaded) {
            setState(() => _savedMeals = state.savedMeals);
          }
          if (state is MealError) {
            setState(() {
              _isSearching = false;
              _searchError = true;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal type selector — choisi avant la recherche
              MealTypeSelectorWidget(
                selected: _selectedMealType,
                onChanged: (t) => setState(() => _selectedMealType = t),
              ),
              const SizedBox(height: 20),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onEditingComplete: () => _triggerSearch(_searchCtrl.text),
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un aliment (ex: Poulet, Riz…)',
                    hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                    prefixIcon: _loadingHistory
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          )
                        : const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          )
                        : _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                                onPressed: () => setState(() {
                                  _selectedFood = null;
                                  _searchCtrl.clear();
                                  _searchResults = [];
                                  _searchError = false;
                                }),
                              )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: AppTypography.body,
                ),
              ),
              const SizedBox(height: 4),

              // Erreur réseau
              if (_searchError && !_isSearching)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Vérifier ta connexion et réessaie',
                        style: AppTypography.caption.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),

              // Résultats de recherche
              if (_searchResults.isNotEmpty && _selectedFood == null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final food = _searchResults[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(food.nom, style: AppTypography.bodyMedium),
                        subtitle: Text(
                          '${food.brand ?? ''}  •  ${food.caloriesPer100g.toInt()} kcal/100g',
                          style: AppTypography.caption,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                        onTap: () => _selectFood(food),
                      );
                    },
                  ),
                ),

              // Hint — aucune recherche encore
              if (_searchResults.isEmpty && !_isSearching && _searchCtrl.text.length < 3)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_rounded, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'Tape le nom d\'un aliment\npour commencer la recherche',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
