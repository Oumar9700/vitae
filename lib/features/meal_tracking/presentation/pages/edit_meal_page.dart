import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/meal_type_selector_widget.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../bloc/meal_bloc.dart';

class EditMealPage extends StatefulWidget {
  final MealEntry entry;

  const EditMealPage({super.key, required this.entry});

  @override
  State<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityCtrl;
  late String _selectedUnit;
  late String _selectedMealType;

  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController(text: widget.entry.quantity.toString());
    _selectedUnit = widget.entry.unit;
    _selectedMealType = widget.entry.mealType;
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  Nutrition get _computedNutrition {
    final qty = double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? widget.entry.quantity;
    final originalQty = widget.entry.quantity;
    if (originalQty <= 0) return widget.entry.nutrition;
    final ratio = qty / originalQty;
    final n = widget.entry.nutrition;
    return Nutrition(
      calories: n.calories * ratio,
      proteinG: n.proteinG * ratio,
      carbsG: n.carbsG * ratio,
      fatsG: n.fatsG * ratio,
      fiberG: n.fiberG * ratio,
      sugarG: n.sugarG * ratio,
      sodiumMg: n.sodiumMg * ratio,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final updatedEntry = widget.entry.copyWith(
      quantity: double.tryParse(_quantityCtrl.text.replaceAll(',', '.')) ?? widget.entry.quantity,
      unit: _selectedUnit,
      mealType: _selectedMealType,
      nutrition: _computedNutrition,
      updatedAt: DateTime.now(),
    );
    context.read<MealBloc>().add(MealUpdateRequested(updatedEntry));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.entry.foodName} modifié'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = _computedNutrition;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Modifier', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food name (read-only)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.entry.foodName, style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quantity + unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: VitaeTextField(
                      label: 'Quantité',
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            filled: true,
                            fillColor: AppColors.bgLight,
                          ),
                          items: AppConstants.foodUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v ?? 'g'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              MealTypeSelectorWidget(
                selected: _selectedMealType,
                onChanged: (t) => setState(() => _selectedMealType = t),
              ),
              const SizedBox(height: 24),

              // Nutrition preview
              Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nutrition recalculée', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        Text('${nutrition.calories.toInt()} kcal', style: AppTypography.h3.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NutritionItem('Protéines', '${nutrition.proteinG.toStringAsFixed(1)}g', AppColors.chartProtein),
                        _NutritionItem('Glucides', '${nutrition.carbsG.toStringAsFixed(1)}g', AppColors.chartCarbs),
                        _NutritionItem('Lipides', '${nutrition.fatsG.toStringAsFixed(1)}g', AppColors.chartFats),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(label: 'Sauvegarder', onPressed: _submit, icon: Icons.check_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.bodyMedium.copyWith(color: color)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
