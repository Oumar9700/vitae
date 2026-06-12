import '../../../meal_tracking/domain/entities/food.dart';

class ParsedMealItem {
  String foodName;
  double quantity;
  String unit;
  double estimatedGrams;
  Food? resolvedFood;

  ParsedMealItem({
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.estimatedGrams,
    this.resolvedFood,
  });

  ParsedMealItem copyWith({
    String? foodName,
    double? quantity,
    String? unit,
    double? estimatedGrams,
    Food? resolvedFood,
  }) {
    return ParsedMealItem(
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedGrams: estimatedGrams ?? this.estimatedGrams,
      resolvedFood: resolvedFood ?? this.resolvedFood,
    );
  }

  double get effectiveGrams {
    if (resolvedFood != null) return estimatedGrams;
    return estimatedGrams;
  }
}
