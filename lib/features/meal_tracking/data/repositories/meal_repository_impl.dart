import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_data_source.dart';
import '../datasources/meal_remote_data_source.dart';
import '../datasources/openfoodfacts_data_source.dart';
import '../models/food_model.dart';
import '../models/meal_entry_model.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource _remote;
  final OpenFoodFactsDataSource _openFoodFacts;
  final MealLocalDataSource _local;

  MealRepositoryImpl({
    required MealRemoteDataSource remote,
    required OpenFoodFactsDataSource openFoodFacts,
    required MealLocalDataSource local,
  })  : _remote = remote,
        _openFoodFacts = openFoodFacts,
        _local = local;

  @override
  Future<Either<Failure, MealEntry>> addMeal(MealEntry entry) async {
    try {
      final model = MealEntryModel.fromEntity(entry);
      final result = await _remote.addMeal(model);
      return Right(result);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MealEntry>> updateMeal(MealEntry entry) async {
    try {
      final model = MealEntryModel.fromEntity(entry);
      final result = await _remote.updateMeal(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String entryId, String userId, DateTime date) async {
    try {
      await _remote.deleteMeal(entryId, userId, date);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<MealEntry>>> getDailyMeals(String userId, DateTime date) async {
    try {
      final entries = await _remote.getDailyMeals(userId, date);
      return Right(entries);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<MealEntry>> watchDailyMeals(String userId, DateTime date) {
    return _remote.watchDailyMeals(userId, date);
  }

  @override
  Future<Either<Failure, List<Food>>> searchFood(String query) async {
    try {
      final results = await _openFoodFacts.searchFood(query);
      return Right(results);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Food?>> getFoodById(String foodId) async {
    try {
      final food = await _openFoodFacts.getProductByBarcode(foodId);
      return Right(food);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Food>>> getRecentFoods(String userId) async {
    try {
      final foods = await _local.getRecentFoods(userId);
      return Right(foods);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveRecentFood(String userId, Food food) async {
    try {
      await _local.saveRecentFood(userId, FoodModel.fromMap({
        'id': food.id,
        'nom': food.nom,
        'brand': food.brand,
        'calories_per_100g': food.caloriesPer100g,
        'protein_per_100g': food.proteinPer100g,
        'carbs_per_100g': food.carbsPer100g,
        'fats_per_100g': food.fatsPer100g,
        'fiber_per_100g': food.fiberPer100g,
        'sugar_per_100g': food.sugarPer100g,
        'sodium_per_100g': food.sodiumPer100g,
        'source': food.source,
        'image_url': food.imageUrl,
      }));
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
