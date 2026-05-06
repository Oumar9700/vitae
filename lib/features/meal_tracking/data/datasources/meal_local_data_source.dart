import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/food_model.dart';

abstract class MealLocalDataSource {
  Future<List<FoodModel>> getRecentFoods(String userId);
  Future<void> saveRecentFood(String userId, FoodModel food);
  Future<List<FoodModel>> getFavoriteFoods(String userId);
  Future<void> saveFavoriteFood(String userId, FoodModel food);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  final SharedPreferences _prefs;

  MealLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  String _recentKey(String userId) => 'recent_foods_$userId';
  String _favKey(String userId) => 'favorite_foods_$userId';

  @override
  Future<List<FoodModel>> getRecentFoods(String userId) async {
    try {
      final json = _prefs.getString(_recentKey(userId));
      if (json == null) return [];
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((m) => FoodModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveRecentFood(String userId, FoodModel food) async {
    try {
      final current = await getRecentFoods(userId);
      final updated = [food, ...current.where((f) => f.id != food.id)]
          .take(AppConstants.recentFoodsMax)
          .toList();
      await _prefs.setString(_recentKey(userId), jsonEncode(updated.map((f) => f.toMap()).toList()));
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<List<FoodModel>> getFavoriteFoods(String userId) async {
    try {
      final json = _prefs.getString(_favKey(userId));
      if (json == null) return [];
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((m) => FoodModel.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveFavoriteFood(String userId, FoodModel food) async {
    try {
      final current = await getFavoriteFoods(userId);
      final updated = [food, ...current.where((f) => f.id != food.id)]
          .take(AppConstants.favoriteFoodsMax)
          .toList();
      await _prefs.setString(_favKey(userId), jsonEncode(updated.map((f) => f.toMap()).toList()));
    } catch (_) {
      throw const CacheException();
    }
  }
}
