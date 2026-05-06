import 'package:equatable/equatable.dart';
import 'food.dart';

class MealEntry extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final String foodName;
  final double quantity;
  final String unit;
  final Nutrition nutrition;
  final String source; // 'manuel', 'photo', 'voix'
  final String? foodId; // référence OpenFoodFacts
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    required this.quantity,
    this.unit = 'g',
    required this.nutrition,
    this.source = 'manuel',
    this.foodId,
    required this.createdAt,
    required this.updatedAt,
  });

  MealEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mealType,
    String? foodName,
    double? quantity,
    String? unit,
    Nutrition? nutrition,
    String? source,
    String? foodId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      nutrition: nutrition ?? this.nutrition,
      source: source ?? this.source,
      foodId: foodId ?? this.foodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, date, mealType, foodName];
}

class DailySummary extends Equatable {
  final DateTime date;
  final Nutrition totalNutrition;
  final Map<String, List<MealEntry>> mealsByType;
  final int score;
  final String scoreLabel;

  const DailySummary({
    required this.date,
    required this.totalNutrition,
    required this.mealsByType,
    required this.score,
    required this.scoreLabel,
  });

  List<MealEntry> get allEntries =>
      mealsByType.values.expand((e) => e).toList();

  @override
  List<Object?> get props => [date, totalNutrition, score];
}
