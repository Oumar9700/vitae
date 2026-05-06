import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../bloc/meal_bloc.dart';

class ManualInputPage extends StatefulWidget {
  final String userId;
  final DateTime date;

  const ManualInputPage({super.key, required this.userId, required this.date});

  @override
  State<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends State<ManualInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '100');

  Food? _selectedFood;
  String _selectedUnit = 'g';
  String _selectedMealType = 'dejeuner';
  Timer? _debounceTimer;
  List<Food> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _quantityCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<MealBloc>().add(MealFoodSearched(query));
      setState(() => _isSearching = true);
    });
  }

  void _selectFood(Food food) {
    setState(() {
      _selectedFood = food;
      _searchCtrl.text = food.nom;
      _searchResults = [];
      _isSearching = false;
    });
    FocusScope.of(context).unfocus();
  }

  Nutrition? get _computedNutrition {
    if (_selectedFood == null) return null;
    final qty = double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? 0;
    if (qty <= 0) return null;
    double qtyG = qty;
    // Convert non-gram units to grams (approximation)
    switch (_selectedUnit) {
      case 'ml': qtyG = qty; break;
      case 'portion': qtyG = qty * 150; break;
      case 'bol': qtyG = qty * 250; break;
      case 'verre': qtyG = qty * 200; break;
      case 'tasse': qtyG = qty * 240; break;
      case 'cuillère à soupe': qtyG = qty * 15; break;
      case 'cuillère à café': qtyG = qty * 5; break;
    }
    return _selectedFood!.nutritionForQuantity(qtyG);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne un aliment dans la liste')),
      );
      return;
    }
    final nutrition = _computedNutrition;
    if (nutrition == null) return;

    final now = DateTime.now();
    final entry = MealEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      date: widget.date,
      mealType: _selectedMealType,
      foodName: _selectedFood!.nom,
      quantity: double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? 100,
      unit: _selectedUnit,
      nutrition: nutrition,
      source: 'manuel',
      foodId: _selectedFood!.id,
      createdAt: now,
      updatedAt: now,
    );

    context.read<MealBloc>().add(MealAddRequested(entry: entry, food: _selectedFood!));
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
            });
          }
          if (state is MealError) {
            setState(() => _isSearching = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                VitaeTextField(
                  label: 'Rechercher un aliment',
                  hint: 'Ex: Poulet, Riz, Pomme...',
                  controller: _searchCtrl,
                  prefixIcon: Icons.search_rounded,
                  suffix: _isSearching
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : _selectedFood != null
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                              onPressed: () => setState(() {
                                _selectedFood = null;
                                _searchCtrl.clear();
                                _searchResults = [];
                              }),
                            )
                          : null,
                  onChanged: _onSearchChanged,
                  validator: (v) => v == null || v.isEmpty ? 'Recherche un aliment' : null,
                ),
                const SizedBox(height: 4),

                // Search results dropdown
                if (_searchResults.isNotEmpty && _selectedFood == null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
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
                          onTap: () => _selectFood(food),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Quantity + unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: VitaeTextField(
                        label: 'Quantité',
                        hint: '100',
                        controller: _quantityCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                        validator: Validators.quantity,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unité', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            style: AppTypography.body,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              filled: true,
                              fillColor: AppColors.bgLight,
                            ),
                            items: AppConstants.foodUnits.map((u) => DropdownMenuItem(value: u, child: Text(u, style: AppTypography.body))).toList(),
                            onChanged: (v) => setState(() => _selectedUnit = v ?? 'g'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Meal type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repas', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.mealTypes.map((type) {
                        final label = AppConstants.mealTypeLabels[type] ?? type;
                        final emoji = AppConstants.mealTypeEmojis[type] ?? '';
                        final selected = _selectedMealType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMealType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primaryPale : AppColors.bgLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
                            ),
                            child: Text(
                              '$emoji $label',
                              style: AppTypography.label.copyWith(color: selected ? AppColors.primary : AppColors.textPrimary),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nutrition preview
                if (_selectedFood != null && _computedNutrition != null) ...[
                  _NutritionPreview(nutrition: _computedNutrition!, foodName: _selectedFood!.nom),
                  const SizedBox(height: 24),
                ],

                PrimaryButton(
                  label: 'Ajouter au journal',
                  onPressed: _submit,
                  icon: Icons.add_rounded,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionPreview extends StatelessWidget {
  final Nutrition nutrition;
  final String foodName;

  const _NutritionPreview({required this.nutrition, required this.foodName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Valeurs nutritionnelles', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
              Text(
                '${nutrition.calories.toInt()} kcal',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip('Protéines', nutrition.proteinG, 'g', AppColors.chartProtein),
              _MacroChip('Glucides', nutrition.carbsG, 'g', AppColors.chartCarbs),
              _MacroChip('Lipides', nutrition.fatsG, 'g', AppColors.chartFats),
              _MacroChip('Fibres', nutrition.fiberG, 'g', AppColors.chartFiber),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MacroChip(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: AppTypography.bodyMedium.copyWith(color: color),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
