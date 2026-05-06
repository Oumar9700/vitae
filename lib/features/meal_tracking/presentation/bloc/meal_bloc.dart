import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../features/authentication/domain/entities/user_profile.dart';

part 'meal_event.dart';
part 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealRepository _mealRepository;
  StreamSubscription? _mealsSubscription;

  MealBloc({required MealRepository mealRepository})
      : _mealRepository = mealRepository,
        super(MealInitial()) {
    on<MealLoadRequested>(_onLoadRequested);
    on<MealAddRequested>(_onAddRequested);
    on<MealUpdateRequested>(_onUpdateRequested);
    on<MealDeleteRequested>(_onDeleteRequested);
    on<MealFoodSearched>(_onFoodSearched);
    on<MealEntriesUpdated>(_onEntriesUpdated);
    on<MealDateChanged>(_onDateChanged);
  }

  void _onLoadRequested(MealLoadRequested event, Emitter<MealState> emit) async {
    emit(MealLoading());
    await _mealsSubscription?.cancel();

    _mealsSubscription = _mealRepository
        .watchDailyMeals(event.userId, event.date)
        .listen((entries) {
      add(MealEntriesUpdated(entries: entries, profile: event.profile, date: event.date));
    });
  }

  void _onEntriesUpdated(MealEntriesUpdated event, Emitter<MealState> emit) {
    final targets = NutritionCalculator.calculateTargets(event.profile);
    final totalNutrition = event.entries.fold(
      Nutrition.zero,
      (acc, e) => acc + e.nutrition,
    );

    final mealsByType = <String, List<MealEntry>>{};
    for (final entry in event.entries) {
      mealsByType.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    final scoreValue = NutritionCalculator.calculateDayScore(
      caloriesConsumed: totalNutrition.calories,
      caloriesTarget: targets.calories,
      proteinConsumed: totalNutrition.proteinG,
      proteinTarget: targets.proteinG,
      carbsConsumed: totalNutrition.carbsG,
      carbsTarget: targets.carbsG,
      fatsConsumed: totalNutrition.fatsG,
      fatsTarget: targets.fatsG,
      sugarConsumed: totalNutrition.sugarG,
      sugarMax: targets.sugarMax,
      sodiumConsumed: totalNutrition.sodiumMg,
      sodiumMax: targets.sodiumMax,
    );

    final summary = DailySummary(
      date: event.date,
      totalNutrition: totalNutrition,
      mealsByType: mealsByType,
      score: scoreValue,
      scoreLabel: NutritionCalculator.scoreLabel(scoreValue),
    );

    emit(MealLoaded(
      summary: summary,
      targets: targets,
      entries: event.entries,
      date: event.date,
    ));
  }

  void _onAddRequested(MealAddRequested event, Emitter<MealState> emit) async {
    final result = await _mealRepository.addMeal(event.entry);
    result.fold(
      (failure) => emit(MealError(failure.message)),
      (_) => null,
    );
    await _mealRepository.saveRecentFood(event.entry.userId, event.food);
  }

  void _onUpdateRequested(MealUpdateRequested event, Emitter<MealState> emit) async {
    final result = await _mealRepository.updateMeal(event.entry);
    result.fold(
      (failure) => emit(MealError(failure.message)),
      (_) => null,
    );
  }

  void _onDeleteRequested(MealDeleteRequested event, Emitter<MealState> emit) async {
    final result = await _mealRepository.deleteMeal(
      event.entryId,
      event.userId,
      event.date,
    );
    result.fold(
      (failure) => emit(MealError(failure.message)),
      (_) => null,
    );
  }

  void _onFoodSearched(MealFoodSearched event, Emitter<MealState> emit) async {
    emit(MealFoodSearchLoading());
    final result = await _mealRepository.searchFood(event.query);
    result.fold(
      (failure) => emit(MealError(failure.message)),
      (foods) => emit(MealFoodSearchResults(foods: foods)),
    );
  }

  void _onDateChanged(MealDateChanged event, Emitter<MealState> emit) {
    add(MealLoadRequested(
      userId: event.userId,
      date: event.date,
      profile: event.profile,
    ));
  }

  @override
  Future<void> close() {
    _mealsSubscription?.cancel();
    return super.close();
  }
}
