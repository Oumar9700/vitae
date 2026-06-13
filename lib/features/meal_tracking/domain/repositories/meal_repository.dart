import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/food.dart';
import '../entities/meal_entry.dart';
import '../entities/saved_meal.dart';

abstract class MealRepository {
  Future<Either<Failure, MealEntry>> addMeal(MealEntry entry);

  Future<Either<Failure, MealEntry>> updateMeal(MealEntry entry);

  Future<Either<Failure, void>> deleteMeal(String entryId, String userId, DateTime date);

  Future<Either<Failure, List<MealEntry>>> getDailyMeals(String userId, DateTime date);

  Future<Either<Failure, Map<DateTime, List<MealEntry>>>> getWeeklyMeals(String userId, DateTime endDate);

  Stream<List<MealEntry>> watchDailyMeals(String userId, DateTime date);

  Future<Either<Failure, List<Food>>> searchFood(String query);

  Future<Either<Failure, Food?>> getFoodById(String foodId);

  Future<Either<Failure, List<Food>>> getRecentFoods(String userId);

  Future<Either<Failure, void>> saveRecentFood(String userId, Food food);

  /// (grammage, date) de la dernière utilisation de cet aliment — peut être (null, null).
  Future<(double?, DateTime?)> getFoodHistory(String userId, String foodId);
  Future<void> saveFoodHistory(String userId, String foodId, double grams);

  Future<Either<Failure, List<SavedMeal>>> getSavedMeals(String userId);
  Future<Either<Failure, void>> addSavedMeal(String userId, SavedMeal meal);
  Future<Either<Failure, void>> deleteSavedMeal(String userId, String mealId);
  Future<void> incrementSavedMealUsed(String userId, String mealId);
}
