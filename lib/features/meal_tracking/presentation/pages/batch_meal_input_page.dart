import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/meal_type_selector_widget.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../bloc/meal_bloc.dart';

/// Lets the user add several foods at once before submitting.
/// Each row has its own food search + quantity + unit.
class BatchMealInputPage extends StatefulWidget {
  final String userId;
  final DateTime date;

  const BatchMealInputPage({super.key, required this.userId, required this.date});

  @override
  State<BatchMealInputPage> createState() => _BatchMealInputPageState();
}

class _BatchMealInputPageState extends State<BatchMealInputPage> {
  String _selectedMealType = 'dejeuner';
  final List<_BatchRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() => _rows.add(_BatchRow()));
  }

  void _removeRow(int index) {
    if (_rows.length == 1) return; // Keep at least one row
    setState(() => _rows.removeAt(index));
  }

  bool get _allValid => _rows.every((r) => r.selectedFood != null && r.quantity > 0);

  void _submit() {
    if (!_allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne un aliment pour chaque ligne')),
      );
      return;
    }

    final now = DateTime.now();
    for (final row in _rows) {
      final food = row.selectedFood!;
      final gFactor = AppConstants.unitToGrams[row.unit] ?? 1.0;
      final grams = row.quantity * gFactor;
      final nutrition = food.nutritionForQuantity(grams);

      final entry = MealEntry(
        id: const Uuid().v4(),
        userId: widget.userId,
        date: widget.date,
        mealType: _selectedMealType,
        foodName: food.nom,
        quantity: row.quantity,
        unit: row.unit,
        nutrition: nutrition,
        source: 'manuel',
        foodId: food.id,
        createdAt: now,
        updatedAt: now,
      );
      context.read<MealBloc>().add(MealAddRequested(entry: entry, food: food));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Repas complet', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(AppIcons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<MealBloc, MealState>(
        listener: (context, state) {
          // Rows handle their own search state individually
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal type
                    MealTypeSelectorWidget(
                      selected: _selectedMealType,
                      onChanged: (t) => setState(() => _selectedMealType = t),
                    ),
                    const SizedBox(height: 20),

                    // Food rows
                    Text('Aliments', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    ...List.generate(_rows.length, (i) {
                      return _BatchRowWidget(
                        key: ValueKey(_rows[i].id),
                        row: _rows[i],
                        canRemove: _rows.length > 1,
                        onRemove: () => _removeRow(i),
                        onChanged: () => setState(() {}),
                      );
                    }),

                    // Add row
                    TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(AppIcons.add, size: 18),
                      label: const Text('Ajouter un aliment'),
                    ),
                    const SizedBox(height: 12),

                    // Summary
                    if (_allValid) _BatchSummary(rows: _rows),
                  ],
                ),
              ),
            ),

            // Submit button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PrimaryButton(
                  label: 'Enregistrer ${_rows.length} aliment${_rows.length > 1 ? 's' : ''}',
                  onPressed: _allValid ? _submit : null,
                  icon: AppIcons.save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model for one row ─────────────────────────────────────────────────

class _BatchRow {
  final String id = const Uuid().v4();
  Food? selectedFood;
  double quantity = 100;
  String unit = 'g';
}

// ─── Row widget ─────────────────────────────────────────────────────────────

class _BatchRowWidget extends StatefulWidget {
  final _BatchRow row;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _BatchRowWidget({
    super.key,
    required this.row,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_BatchRowWidget> createState() => _BatchRowWidgetState();
}

class _BatchRowWidgetState extends State<_BatchRowWidget> {
  final _searchCtrl = TextEditingController();
  final _qtyCtrl    = TextEditingController(text: '100');
  Timer? _debounce;
  List<Food> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.trim().length < 3) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 800), () {
      context.read<MealBloc>().add(MealFoodSearched(q.trim()));
      setState(() => _searching = true);
    });
  }

  void _select(Food food) {
    setState(() {
      widget.row.selectedFood = food;
      _searchCtrl.text = food.nom;
      _results = [];
      _searching = false;
    });
    widget.onChanged();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealBloc, MealState>(
      listener: (_, state) {
        if (state is MealFoodSearchResults && _searching) {
          setState(() {
            _results   = state.foods;
            _searching = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Search + delete row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Aliment…',
                      hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
                      prefixIcon: const Icon(AppIcons.search, size: 18, color: AppColors.textSecondary),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                            )
                          : widget.row.selectedFood != null
                              ? IconButton(
                                  icon: const Icon(AppIcons.close, size: 16, color: AppColors.textSecondary),
                                  onPressed: () {
                                    setState(() {
                                      widget.row.selectedFood = null;
                                      _searchCtrl.clear();
                                      _results = [];
                                    });
                                    widget.onChanged();
                                  },
                                )
                              : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      filled: true,
                      fillColor: AppColors.bgWhite,
                    ),
                    style: AppTypography.body,
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(AppIcons.delete, size: 20, color: AppColors.error),
                    onPressed: widget.onRemove,
                    tooltip: 'Supprimer',
                  ),
              ],
            ),

            // Search results dropdown
            if (_results.isNotEmpty && widget.row.selectedFood == null)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 3))],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final food = _results[i];
                    return ListTile(
                      dense: true,
                      title: Text(food.nom, style: AppTypography.label),
                      subtitle: Text('${food.caloriesPer100g.toInt()} kcal/100g', style: AppTypography.caption),
                      onTap: () => _select(food),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Quantity + unit
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    decoration: InputDecoration(
                      labelText: 'Qté',
                      labelStyle: AppTypography.caption,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      filled: true,
                      fillColor: AppColors.bgWhite,
                    ),
                    style: AppTypography.body,
                    onChanged: (v) {
                      widget.row.quantity = double.tryParse(v.replaceAll(',', '.')) ?? 100;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: widget.row.unit,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
                      filled: true,
                      fillColor: AppColors.bgWhite,
                    ),
                    items: AppConstants.foodUnits
                        .map((u) => DropdownMenuItem(value: u, child: Text(u, style: AppTypography.body)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => widget.row.unit = v ?? 'g');
                      widget.onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Batch summary ───────────────────────────────────────────────────────────

class _BatchSummary extends StatelessWidget {
  final List<_BatchRow> rows;

  const _BatchSummary({required this.rows});

  @override
  Widget build(BuildContext context) {
    double totalCal = 0;
    double totalProt = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final r in rows) {
      if (r.selectedFood == null) continue;
      final g = r.quantity * (AppConstants.unitToGrams[r.unit] ?? 1.0);
      final n = r.selectedFood!.nutritionForQuantity(g);
      totalCal  += n.calories;
      totalProt += n.proteinG;
      totalCarbs += n.carbsG;
      totalFats += n.fatsG;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPale,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.calories, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Total du repas', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${totalCal.toInt()} kcal', style: AppTypography.h3.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryChip('Prot.', totalProt, AppColors.chartProtein),
              _SummaryChip('Gluc.', totalCarbs, AppColors.chartCarbs),
              _SummaryChip('Lip.', totalFats, AppColors.chartFats),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}g', style: AppTypography.bodyMedium.copyWith(color: color)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
