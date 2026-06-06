import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/saved_meal.dart';
import '../models/food_model.dart';

abstract class MealLocalDataSource {
  Future<List<FoodModel>> getRecentFoods(String userId);
  Future<void> saveRecentFood(String userId, FoodModel food);
  Future<List<FoodModel>> getFavoriteFoods(String userId);
  Future<void> saveFavoriteFood(String userId, FoodModel food);

  /// Retourne (grammage, date) de la dernière utilisation de cet aliment, ou (null, null).
  Future<(double?, DateTime?)> getFoodHistory(String userId, String foodId);
  Future<void> saveFoodHistory(String userId, String foodId, double grams);

  Future<List<SavedMeal>> getSavedMeals(String userId);
  Future<void> addSavedMeal(String userId, SavedMeal meal);
  Future<void> deleteSavedMeal(String userId, String mealId);
  Future<void> incrementSavedMealUsed(String userId, String mealId);
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

  // ─── Food History ───────────────────────────────────────────────────────────

  String _historyKey(String userId) => 'food_history_$userId';

  @override
  Future<(double?, DateTime?)> getFoodHistory(String userId, String foodId) async {
    try {
      final json = _prefs.getString(_historyKey(userId));
      if (json == null) return (null, null);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (!map.containsKey(foodId)) return (null, null);
      final entry = map[foodId] as Map<String, dynamic>;
      final grams = (entry['grams'] as num?)?.toDouble();
      final date = entry['date'] != null ? DateTime.tryParse(entry['date']) : null;
      return (grams, date);
    } catch (_) {
      return (null, null);
    }
  }

  @override
  Future<void> saveFoodHistory(String userId, String foodId, double grams) async {
    try {
      final json = _prefs.getString(_historyKey(userId));
      final map = json != null ? (jsonDecode(json) as Map<String, dynamic>) : <String, dynamic>{};
      map[foodId] = {'grams': grams, 'date': DateTime.now().toIso8601String()};
      await _prefs.setString(_historyKey(userId), jsonEncode(map));
    } catch (_) {
      // Silently ignore — history is non-critical
    }
  }

  // ─── Saved Meals ────────────────────────────────────────────────────────────

  String _savedMealsKey(String userId) => 'saved_meals_$userId';

  @override
  Future<List<SavedMeal>> getSavedMeals(String userId) async {
    try {
      final json = _prefs.getString(_savedMealsKey(userId));
      if (json == null) return [];
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((m) => SavedMeal.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addSavedMeal(String userId, SavedMeal meal) async {
    try {
      final current = await getSavedMeals(userId);
      final updated = [meal, ...current.where((m) => m.id != meal.id)];
      await _prefs.setString(
          _savedMealsKey(userId), jsonEncode(updated.map((m) => m.toMap()).toList()));
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> deleteSavedMeal(String userId, String mealId) async {
    try {
      final current = await getSavedMeals(userId);
      final updated = current.where((m) => m.id != mealId).toList();
      await _prefs.setString(
          _savedMealsKey(userId), jsonEncode(updated.map((m) => m.toMap()).toList()));
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> incrementSavedMealUsed(String userId, String mealId) async {
    try {
      final current = await getSavedMeals(userId);
      final updated = current.map((m) => m.id == mealId ? m.copyWith(timesUsed: m.timesUsed + 1) : m).toList();
      await _prefs.setString(
          _savedMealsKey(userId), jsonEncode(updated.map((m) => m.toMap()).toList()));
    } catch (_) {
      // Non-critical
    }
  }
}
