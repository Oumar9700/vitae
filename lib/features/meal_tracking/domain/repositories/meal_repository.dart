import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/food.dart';
import '../entities/meal_entry.dart';

abstract class MealRepository {
  Future<Either<Failure, MealEntry>> addMeal(MealEntry entry);

  Future<Either<Failure, MealEntry>> updateMeal(MealEntry entry);

  Future<Either<Failure, void>> deleteMeal(String entryId, String userId, DateTime date);

  Future<Either<Failure, List<MealEntry>>> getDailyMeals(String userId, DateTime date);

  Stream<List<MealEntry>> watchDailyMeals(String userId, DateTime date);

  Future<Either<Failure, List<Food>>> searchFood(String query);

  Future<Either<Failure, Food?>> getFoodById(String foodId);

  Future<Either<Failure, List<Food>>> getRecentFoods(String userId);

  Future<Either<Failure, void>> saveRecentFood(String userId, Food food);
}
