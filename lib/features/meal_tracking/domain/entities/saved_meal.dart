import 'package:equatable/equatable.dart';
import 'food.dart';

class SavedMealItem extends Equatable {
  final String foodId;
  final String foodName;
  final double grams;
  final Nutrition nutrition;

  const SavedMealItem({
    required this.foodId,
    required this.foodName,
    required this.grams,
    required this.nutrition,
  });

  Map<String, dynamic> toMap() => {
        'food_id': foodId,
        'food_name': foodName,
        'grams': grams,
        'calories': nutrition.calories,
        'protein_g': nutrition.proteinG,
        'carbs_g': nutrition.carbsG,
        'fats_g': nutrition.fatsG,
        'fiber_g': nutrition.fiberG,
        'sugar_g': nutrition.sugarG,
        'sodium_mg': nutrition.sodiumMg,
      };

  factory SavedMealItem.fromMap(Map<String, dynamic> m) => SavedMealItem(
        foodId: m['food_id'] ?? '',
        foodName: m['food_name'] ?? '',
        grams: (m['grams'] ?? 0).toDouble(),
        nutrition: Nutrition(
          calories: (m['calories'] ?? 0).toDouble(),
          proteinG: (m['protein_g'] ?? 0).toDouble(),
          carbsG: (m['carbs_g'] ?? 0).toDouble(),
          fatsG: (m['fats_g'] ?? 0).toDouble(),
          fiberG: (m['fiber_g'] ?? 0).toDouble(),
          sugarG: (m['sugar_g'] ?? 0).toDouble(),
          sodiumMg: (m['sodium_mg'] ?? 0).toDouble(),
        ),
      );

  @override
  List<Object?> get props => [foodId, grams];
}

class SavedMeal extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final List<SavedMealItem> items;
  final double totalCalories;
  final int timesUsed;
  final DateTime createdAt;

  const SavedMeal({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.items,
    required this.totalCalories,
    this.timesUsed = 0,
    required this.createdAt,
  });

  SavedMeal copyWith({int? timesUsed}) => SavedMeal(
        id: id,
        userId: userId,
        name: name,
        icon: icon,
        items: items,
        totalCalories: totalCalories,
        timesUsed: timesUsed ?? this.timesUsed,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'icon': icon,
        'items': items.map((i) => i.toMap()).toList(),
        'total_calories': totalCalories,
        'times_used': timesUsed,
        'created_at': createdAt.toIso8601String(),
      };

  factory SavedMeal.fromMap(Map<String, dynamic> m) => SavedMeal(
        id: m['id'] ?? '',
        userId: m['user_id'] ?? '',
        name: m['name'] ?? '',
        icon: m['icon'] ?? '🍽️',
        items: (m['items'] as List<dynamic>? ?? [])
            .map((i) => SavedMealItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        totalCalories: (m['total_calories'] ?? 0).toDouble(),
        timesUsed: m['times_used'] ?? 0,
        createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, name];
}
