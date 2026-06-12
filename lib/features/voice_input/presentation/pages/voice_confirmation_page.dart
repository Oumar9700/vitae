import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../di/injection_container.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/meal_type_selector_widget.dart';
import '../../../meal_tracking/domain/entities/food.dart';
import '../../../meal_tracking/domain/entities/meal_entry.dart';
import '../../../meal_tracking/domain/repositories/meal_repository.dart';
import '../../../meal_tracking/presentation/bloc/meal_bloc.dart';
import '../../domain/entities/parsed_meal_item.dart';

class VoiceConfirmationPage extends StatefulWidget {
  final List<ParsedMealItem> items;
  final String transcription;
  final String userId;
  final DateTime date;

  const VoiceConfirmationPage({
    super.key,
    required this.items,
    required this.transcription,
    required this.userId,
    required this.date,
  });

  @override
  State<VoiceConfirmationPage> createState() => _VoiceConfirmationPageState();
}

class _VoiceConfirmationPageState extends State<VoiceConfirmationPage> {
  late List<_ItemState> _items;
  String _mealType = 'dejeuner';

  @override
  void initState() {
    super.initState();
    _mealType = _detectMealType();
    _items = widget.items
        .map((p) => _ItemState(parsed: p, loading: true))
        .toList();
    for (var i = 0; i < _items.length; i++) {
      _autoSearch(i);
    }
  }

  String _detectMealType() {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 11) return 'petit_dejeuner';
    if (h >= 11 && h < 15) return 'dejeuner';
    if (h >= 15 && h < 19) return 'gouter';
    if (h >= 19 && h < 23) return 'diner';
    return 'snack';
  }

  Future<void> _autoSearch(int index) async {
    final foodName = index < _items.length ? _items[index].parsed.foodName : null;
    if (foodName == null) return;
    final result = await sl<MealRepository>().searchFood(foodName);
    if (!mounted || index >= _items.length) return;
    result.fold(
      (_) => setState(() {
        _items[index] = _items[index].withFood(null);
      }),
      (foods) => setState(() {
        _items[index] =
            _items[index].withFood(foods.isNotEmpty ? foods.first : null);
      }),
    );
  }

  Future<void> _searchFoodForItem(int index) async {
    final food = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _FoodSearchSheet(initialQuery: _items[index].parsed.foodName),
    );
    if (food != null && mounted) {
      setState(() => _items[index] = _items[index].withFood(food));
    }
  }

  void _updateQty(int index, String raw) {
    final qty = double.tryParse(raw.replaceAll(',', '.'));
    if (qty == null || qty <= 0) return;
    final item = _items[index];
    final gramsPerUnit = AppConstants.unitToGrams[item.parsed.unit] ?? 100.0;
    final newGrams = (qty * gramsPerUnit).clamp(1.0, 2000.0);
    setState(() {
      _items[index] = item.copyWith(
        parsed: item.parsed.copyWith(quantity: qty, estimatedGrams: newGrams),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].qtyCtrl.dispose();
      _items.removeAt(index);
    });
  }

  void _addAll() {
    final now = DateTime.now();
    for (final item in _items) {
      final food = item.resolvedFood;
      if (food == null) continue;
      final grams = item.parsed.estimatedGrams;
      final entry = MealEntry(
        id: const Uuid().v4(),
        userId: widget.userId,
        date: widget.date,
        mealType: _mealType,
        foodName: food.nom,
        quantity: grams,
        unit: item.parsed.unit,
        nutrition: food.nutritionForQuantity(grams),
        source: 'voix',
        foodId: food.id,
        createdAt: now,
        updatedAt: now,
      );
      context.read<MealBloc>().add(MealAddRequested(entry: entry, food: food));
      sl<MealRepository>().saveFoodHistory(widget.userId, food.id, grams);
    }
    Navigator.of(context).pop(true);
  }

  // ── Total nutrition ────────────────────────────────────────────────────────

  ({double cal, double p, double c, double f}) get _totals {
    double cal = 0, p = 0, c = 0, f = 0;
    for (final item in _items) {
      final food = item.resolvedFood;
      if (food == null) continue;
      final n = food.nutritionForQuantity(item.parsed.estimatedGrams);
      cal += n.calories;
      p += n.proteinG;
      c += n.carbsG;
      f += n.fatsG;
    }
    return (cal: cal, p: p, c: c, f: f);
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.qtyCtrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCount = _items.where((i) => i.resolvedFood != null).length;
    final t = _totals;

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: Text('Repas détecté', style: AppTypography.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TranscriptionCard(text: widget.transcription),
            const SizedBox(height: 20),

            MealTypeSelectorWidget(
              selected: _mealType,
              onChanged: (t) => setState(() => _mealType = t),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Text('Aliments détectés',
                    style: AppTypography.h3.copyWith(fontSize: 16)),
                const Spacer(),
                Text(
                  '${_items.length} aliment${_items.length > 1 ? 's' : ''}',
                  style: AppTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Glissez vers la gauche pour supprimer',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),

            if (_items.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Aucun aliment restant.',
                      style: AppTypography.caption),
                ),
              )
            else
              ...List.generate(_items.length, (i) {
                final itemState = _items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(itemState.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeItem(i),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white, size: 24),
                    ),
                    child: _ItemCard(
                      state: itemState,
                      onDelete: () => _removeItem(i),
                      onSearch: () => _searchFoodForItem(i),
                      onQtyChanged: (v) => _updateQty(i, v),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total nutrition preview
              if (resolvedCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TotalPill('${t.cal.toInt()} kcal',
                          AppColors.textPrimary, 'Total'),
                      _TotalPill('P ${t.p.toStringAsFixed(0)}g',
                          AppColors.chartProtein, 'Protéines'),
                      _TotalPill('G ${t.c.toStringAsFixed(0)}g',
                          AppColors.chartCarbs, 'Glucides'),
                      _TotalPill('L ${t.f.toStringAsFixed(0)}g',
                          AppColors.chartFats, 'Lipides'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              PrimaryButton(
                label: resolvedCount > 0
                    ? 'Ajouter $resolvedCount aliment${resolvedCount > 1 ? 's' : ''} au journal'
                    : 'Aucun aliment résolu',
                icon: Icons.check_rounded,
                onPressed: resolvedCount > 0 ? _addAll : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Item State ───────────────────────────────────────────────────────────────

class _ItemState {
  final String id;
  final ParsedMealItem parsed;
  final Food? resolvedFood;
  final bool loading;
  final TextEditingController qtyCtrl;

  _ItemState({
    String? id,
    required this.parsed,
    this.resolvedFood,
    this.loading = false,
    TextEditingController? qtyCtrl,
  })  : id = id ?? UniqueKey().toString(),
        qtyCtrl = qtyCtrl ??
            TextEditingController(
              text: parsed.quantity == parsed.quantity.roundToDouble()
                  ? parsed.quantity.toInt().toString()
                  : parsed.quantity.toStringAsFixed(1),
            );

  // Utiliser withFood() pour mettre à jour resolvedFood (supporte null explicite)
  _ItemState withFood(Food? food) => _ItemState(
        id: id,
        parsed: parsed,
        resolvedFood: food,
        loading: false,
        qtyCtrl: qtyCtrl,
      );

  _ItemState copyWith({ParsedMealItem? parsed, bool? loading}) => _ItemState(
        id: id,
        parsed: parsed ?? this.parsed,
        resolvedFood: resolvedFood,
        loading: loading ?? this.loading,
        qtyCtrl: qtyCtrl,
      );
}

// ─── Item Card ────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final _ItemState state;
  final VoidCallback onDelete;
  final VoidCallback onSearch;
  final ValueChanged<String> onQtyChanged;

  const _ItemCard({
    required this.state,
    required this.onDelete,
    required this.onSearch,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final food = state.resolvedFood;
    final parsed = state.parsed;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: food != null
              ? AppColors.accent.withValues(alpha: 0.4)
              : state.loading
                  ? AppColors.border
                  : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food chip + delete
          Row(
            children: [
              Expanded(
                child: state.loading
                    ? Row(children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Recherche "${parsed.foodName}"…',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ])
                    : food != null
                        ? _ResolvedFoodChip(food: food, onTap: onSearch)
                        : _NotFoundRow(
                            foodName: parsed.foodName, onSearch: onSearch),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textTertiary),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),

          // Quantity row
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.scale_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text('Quantité :', style: AppTypography.caption),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                height: 34,
                child: TextField(
                  controller: state.qtyCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.bodyMedium.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  // Mise à jour en temps réel
                  onChanged: onQtyChanged,
                  onSubmitted: onQtyChanged,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                parsed.unit,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '≈ ${parsed.estimatedGrams.toInt()} g',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),

          // Nutrition mini-bar (si aliment résolu)
          if (food != null) ...[
            const SizedBox(height: 8),
            _NutritionMini(food: food, grams: parsed.estimatedGrams),
          ],
        ],
      ),
    );
  }
}

// ─── Chips ────────────────────────────────────────────────────────────────────

class _ResolvedFoodChip extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  const _ResolvedFoodChip({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 14, color: AppColors.accent),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                food.nom,
                style: AppTypography.label.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_rounded,
                size: 12, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _NotFoundRow extends StatelessWidget {
  final String foodName;
  final VoidCallback onSearch;
  const _NotFoundRow(
      {required this.foodName, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '"$foodName"',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.error),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSearch,
          child: Text(
            'Rechercher',
            style: AppTypography.label.copyWith(
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Nutrition widgets ────────────────────────────────────────────────────────

class _NutritionMini extends StatelessWidget {
  final Food food;
  final double grams;
  const _NutritionMini({required this.food, required this.grams});

  @override
  Widget build(BuildContext context) {
    final n = food.nutritionForQuantity(grams);
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _Pill('${n.calories.toInt()} kcal', AppColors.textPrimary),
        _Pill('P ${n.proteinG.toStringAsFixed(1)}g',
            AppColors.chartProtein),
        _Pill('G ${n.carbsG.toStringAsFixed(1)}g', AppColors.chartCarbs),
        _Pill('L ${n.fatsG.toStringAsFixed(1)}g', AppColors.chartFats),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _TotalPill extends StatelessWidget {
  final String value;
  final Color color;
  final String label;
  const _TotalPill(this.value, this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: AppTypography.label.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }
}

// ─── Transcription Card ───────────────────────────────────────────────────────

class _TranscriptionCard extends StatefulWidget {
  final String text;
  const _TranscriptionCard({required this.text});

  @override
  State<_TranscriptionCard> createState() => _TranscriptionCardState();
}

class _TranscriptionCardState extends State<_TranscriptionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mic_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"${widget.text}"',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: _expanded ? null : 2,
                overflow: _expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Food Search Sheet ────────────────────────────────────────────────────────

class _FoodSearchSheet extends StatefulWidget {
  final String initialQuery;
  const _FoodSearchSheet({required this.initialQuery});

  @override
  State<_FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<_FoodSearchSheet> {
  late TextEditingController _ctrl;
  List<Food> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    _search(widget.initialQuery);
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) return;
    setState(() {
      _searching = true;
      _results = [];
    });
    final result = await sl<MealRepository>().searchFood(query.trim());
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _searching = false),
      (foods) => setState(() {
        _results = foods;
        _searching = false;
      }),
    );
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(v));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rechercher un aliment', style: AppTypography.h3),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex : poulet, riz, lait…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _onChanged,
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty && !_searching
                  ? Center(
                      child: Text('Aucun résultat.',
                          style: AppTypography.caption))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final food = _results[i];
                        return ListTile(
                          title: Text(food.nom,
                              style: AppTypography.bodyMedium),
                          subtitle: Text(
                            '${food.caloriesPer100g.toInt()} kcal / 100g',
                            style: AppTypography.caption,
                          ),
                          trailing: const Icon(Icons.add_rounded,
                              color: AppColors.primary),
                          onTap: () =>
                              Navigator.pop(context, food),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
