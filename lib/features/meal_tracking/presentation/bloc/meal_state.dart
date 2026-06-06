part of 'meal_bloc.dart';

abstract class MealState extends Equatable {
  const MealState();
  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final DailySummary summary;
  final NutritionTargets targets;
  final List<MealEntry> entries;
  final DateTime date;

  const MealLoaded({
    required this.summary,
    required this.targets,
    required this.entries,
    required this.date,
  });

  @override
  List<Object?> get props => [summary, date, entries.length];
}

class MealFoodSearchLoading extends MealState {}

class MealFoodSearchResults extends MealState {
  final List<Food> foods;
  const MealFoodSearchResults({required this.foods});
  @override
  List<Object?> get props => [foods];
}

class MealError extends MealState {
  final String message;
  const MealError(this.message);
  @override
  List<Object?> get props => [message];
}

class MealSavedMealsLoaded extends MealState {
  final List<SavedMeal> savedMeals;
  const MealSavedMealsLoaded(this.savedMeals);
  @override
  List<Object?> get props => [savedMeals];
}
