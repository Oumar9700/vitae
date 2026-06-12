import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/constants/app_icons.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/services/app_routes.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/meal_entry.dart';
import '../bloc/meal_bloc.dart';
import '../widgets/advice_card.dart';
import '../widgets/character_widget.dart';
import '../widgets/meal_card_widget.dart';
import '../widgets/nutrition_bars_widget.dart';
import '../../../../di/injection_container.dart';
import '../../../barcode_scanning/presentation/bloc/barcode_bloc.dart';
import '../../../barcode_scanning/presentation/pages/barcode_scanner_page.dart';
import '../../../voice_input/presentation/bloc/voice_bloc.dart';
import '../../../voice_input/presentation/pages/voice_input_page.dart';
import 'batch_meal_input_page.dart';
import 'edit_meal_page.dart';
import 'manual_input_page.dart';
import 'analytics_panel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MealBloc>().add(MealLoadRequested(
            userId: authState.user.uid,
            date: _selectedDate,
            profile: authState.user,
          ));
    }
  }

  void _changeDate(int delta) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: delta)));
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MealBloc>().add(MealDateChanged(
            userId: authState.user.uid,
            date: _selectedDate,
            profile: authState.user,
          ));
    }
  }

  void _openAnalytics(BuildContext ctx, MealLoaded state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnalyticsPanel(summary: state.summary, targets: state.targets),
    );
  }

  void _showAddOptions(BuildContext ctx) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddOptionsSheet(
        onManual: () {
          Navigator.pop(ctx);
          Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: ctx.read<MealBloc>(),
              child: ManualInputPage(
                userId: authState.user.uid,
                date: _selectedDate,
              ),
            ),
          ));
        },
        onBatch: () {
          Navigator.pop(ctx);
          Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: ctx.read<MealBloc>(),
              child: BatchMealInputPage(
                userId: authState.user.uid,
                date: _selectedDate,
              ),
            ),
          ));
        },
        onScan: () {
          Navigator.pop(ctx);
          Navigator.push(ctx, MaterialPageRoute(
            builder: (newCtx) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<BarcodeBloc>()),
                BlocProvider.value(value: ctx.read<MealBloc>()),
              ],
              child: BarcodeScannerPage(
                userId: authState.user.uid,
                date: _selectedDate,
              ),
            ),
          ));
        },
        onVoice: () {
          Navigator.pop(ctx);
          Navigator.push(ctx, MaterialPageRoute(
            builder: (newCtx) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<VoiceBloc>()),
                BlocProvider.value(value: ctx.read<MealBloc>()),
              ],
              child: VoiceInputPage(
                userId: authState.user.uid,
                date: _selectedDate,
              ),
            ),
          ));
        },
      ),
    );
  }

  void _editEntry(BuildContext ctx, MealEntry entry) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: ctx.read<MealBloc>(),
        child: EditMealPage(entry: entry),
      ),
    ));
  }

  void _deleteEntry(MealEntry entry) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<MealBloc>().add(MealDeleteRequested(
          entryId: entry.id,
          userId: authState.user.uid,
          date: entry.date,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.foodName} supprimé'),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: AppColors.primaryLight,
          onPressed: () => context.read<MealBloc>().add(MealAddRequested(
                entry: entry,
                food: _dummyFood(entry),
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: _buildAppBar(),
      body: BlocConsumer<MealBloc, MealState>(
        listener: (context, state) {
          if (state is MealError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is MealLoading || state is MealInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is MealLoaded) {
            return _buildContent(context, state);
          }
          return _buildContent(context, null);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Ajouter', style: AppTypography.button.copyWith(fontSize: 14)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            onPressed: () => _changeDate(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _selectedDate = DateTime.now()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedDate.formattedFr,
                  style: AppTypography.h3,
                ),
                if (_selectedDate.isToday)
                  Text("Aujourd'hui", style: AppTypography.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            onPressed: _selectedDate.isToday ? null : () => _changeDate(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.settings),
          onPressed: () => context.go(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, MealLoaded? state) {
    final targets = state?.targets;
    final summary = state?.summary;
    final total = summary?.totalNutrition;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadMeals(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),

                // Character
                Center(
                  child: CharacterWidget(
                    caloriesRatio: targets != null && targets.calories > 0
                        ? (total?.calories ?? 0) / targets.calories
                        : 0,
                    proteinsLow: targets != null &&
                        (total?.proteinG ?? 0) < targets.proteinG * 0.7,
                    sugarHigh: targets != null &&
                        (total?.sugarG ?? 0) > targets.sugarMax * 0.9,
                  ),
                ),
                const SizedBox(height: 28),

                // Calorie Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: CalorieProgressWidget(
                    consumed: total?.calories ?? 0,
                    target: targets?.calories ?? AppConstants.defaultCalories.toDouble(),
                  ),
                ),
                const SizedBox(height: 16),

                // Macros
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Macronutriments', style: AppTypography.h3.copyWith(fontSize: 15)),
                      const SizedBox(height: 16),
                      MacroBarWidget(
                        label: 'Protéines',
                        consumed: total?.proteinG ?? 0,
                        target: targets?.proteinG ?? AppConstants.defaultProtein,
                        color: AppColors.chartProtein,
                      ),
                      const SizedBox(height: 14),
                      MacroBarWidget(
                        label: 'Glucides',
                        consumed: total?.carbsG ?? 0,
                        target: targets?.carbsG ?? AppConstants.defaultCarbs,
                        color: AppColors.chartCarbs,
                      ),
                      const SizedBox(height: 14),
                      MacroBarWidget(
                        label: 'Lipides',
                        consumed: total?.fatsG ?? 0,
                        target: targets?.fatsG ?? AppConstants.defaultFats,
                        color: AppColors.chartFats,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Health indicators
                Row(
                  children: [
                    Expanded(
                      child: HealthIndicatorChip(
                        label: 'Fibres',
                        value: total?.fiberG ?? 0,
                        max: targets?.fiberMin ?? 25,
                        unit: 'g',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HealthIndicatorChip(
                        label: 'Sucres',
                        value: total?.sugarG ?? 0,
                        max: targets?.sugarMax ?? 50,
                        unit: 'g',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HealthIndicatorChip(
                        label: 'Sodium',
                        value: total?.sodiumMg ?? 0,
                        max: targets?.sodiumMax ?? 2300,
                        unit: 'mg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Analytics button
                if (state != null)
                  OutlinedButton.icon(
                    onPressed: () => _openAnalytics(context, state),
                    icon: const Icon(Icons.bar_chart_rounded, size: 18),
                    label: Text(
                      'Voir les détails du jour  (Score: ${state.summary.scoreLabel})',
                      style: AppTypography.label.copyWith(color: AppColors.primary),
                    ),
                  ),
                const SizedBox(height: 16),

                // Advice card
                const AdviceCard(),
                const SizedBox(height: 24),

                // Meals list
                if (summary != null && summary.mealsByType.isNotEmpty) ...[
                  Text('Repas du jour', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  ...AppConstants.mealTypes.map((type) {
                    final entries = summary.mealsByType[type] ?? [];
                    return MealSectionWidget(
                      mealType: type,
                      entries: entries,
                      onEdit: (e) => _editEntry(context, e),
                      onDelete: _deleteEntry,
                    );
                  }),
                ] else ...[
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text('Aucun repas enregistré', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Ajoute ton premier repas!', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to reconstruct a pseudo food for undo
  dynamic _dummyFood(MealEntry entry) {
    return entry; // used only as Food reference in undo - won't actually re-fetch nutrition
  }
}

class _AddOptionsSheet extends StatelessWidget {
  final VoidCallback onManual;
  final VoidCallback onBatch;
  final VoidCallback onScan;
  final VoidCallback onVoice;

  const _AddOptionsSheet({
    required this.onManual,
    required this.onBatch,
    required this.onScan,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter un aliment', style: AppTypography.h3),
            const SizedBox(height: 20),
            _optionTile(
              context,
              icon: AppIcons.food,
              color: AppColors.primary,
              title: 'Saisie manuelle',
              subtitle: 'Rechercher un aliment dans CIQUAL / OpenFoodFacts',
              onTap: onManual,
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              icon: AppIcons.batch,
              color: AppColors.accent,
              title: 'Repas complet',
              subtitle: 'Ajouter plusieurs aliments en une fois',
              onTap: onBatch,
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              icon: Icons.qr_code_scanner_rounded,
              color: AppColors.chartFats,
              title: 'Scanner un code-barres',
              subtitle: 'Produits packagés via OpenFoodFacts',
              onTap: onScan,
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              icon: Icons.mic_rounded,
              color: AppColors.chartProtein,
              title: 'Saisie vocale',
              subtitle: 'Dictez votre repas en français',
              onTap: onVoice,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
