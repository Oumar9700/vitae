import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/meal_entry.dart';

class MealEntryModel extends MealEntry {
  const MealEntryModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.mealType,
    required super.foodName,
    required super.quantity,
    super.unit,
    required super.nutrition,
    super.source,
    super.foodId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MealEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    return MealEntryModel(
      id: id,
      userId: map['user_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      mealType: map['meal_type'] ?? 'dejeuner',
      foodName: map['food_name'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'g',
      nutrition: Nutrition(
        calories: (map['calories'] ?? 0).toDouble(),
        proteinG: (map['protein_g'] ?? 0).toDouble(),
        carbsG: (map['carbs_g'] ?? 0).toDouble(),
        fatsG: (map['fats_g'] ?? 0).toDouble(),
        fiberG: (map['fiber_g'] ?? 0).toDouble(),
        sugarG: (map['sugar_g'] ?? 0).toDouble(),
        sodiumMg: (map['sodium_mg'] ?? 0).toDouble(),
      ),
      source: map['source'] ?? 'manuel',
      foodId: map['food_id'],
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MealEntryModel.fromEntity(MealEntry entry) {
    return MealEntryModel(
      id: entry.id,
      userId: entry.userId,
      date: entry.date,
      mealType: entry.mealType,
      foodName: entry.foodName,
      quantity: entry.quantity,
      unit: entry.unit,
      nutrition: entry.nutrition,
      source: entry.source,
      foodId: entry.foodId,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'date': Timestamp.fromDate(date),
      'meal_type': mealType,
      'food_name': foodName,
      'quantity': quantity,
      'unit': unit,
      'calories': nutrition.calories,
      'protein_g': nutrition.proteinG,
      'carbs_g': nutrition.carbsG,
      'fats_g': nutrition.fatsG,
      'fiber_g': nutrition.fiberG,
      'sugar_g': nutrition.sugarG,
      'sodium_mg': nutrition.sodiumMg,
      'source': source,
      'food_id': foodId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
