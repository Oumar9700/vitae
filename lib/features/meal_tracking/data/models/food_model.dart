import 'package:openfoodfacts/openfoodfacts.dart';
import '../../domain/entities/food.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.nom,
    super.brand,
    required super.caloriesPer100g,
    required super.proteinPer100g,
    required super.carbsPer100g,
    required super.fatsPer100g,
    super.fiberPer100g,
    super.sugarPer100g,
    super.sodiumPer100g,
    super.source,
    super.imageUrl,
  });

  factory FoodModel.fromProduct(Product product) {
    final n = product.nutriments;

    // Prefer kcal directly; fallback to kJ conversion (1 kcal = 4.184 kJ)
    final kcal = n?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams);
    final kj = n?.getValue(Nutrient.energyKJ, PerSize.oneHundredGrams);
    final calories = kcal ?? (kj != null ? kj / 4.184 : 0.0);

    return FoodModel(
      id: product.barcode ?? '',
      nom: product.getBestProductName(OpenFoodFactsLanguage.FRENCH),
      brand: product.brands,
      caloriesPer100g: calories,
      proteinPer100g: n?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0.0,
      carbsPer100g: n?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0.0,
      fatsPer100g: n?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0.0,
      fiberPer100g: n?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0.0,
      sugarPer100g: n?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0.0,
      // SDK returns sodium in g, convert to mg
      sodiumPer100g: (n?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0.0) * 1000,
      source: 'openfoods',
      imageUrl: product.imageFrontUrl ?? product.imageFrontSmallUrl,
    );
  }

  factory FoodModel.manual({
    required String id,
    required String nom,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    double fiberPer100g = 0,
    double sugarPer100g = 0,
    double sodiumPer100g = 0,
  }) {
    return FoodModel(
      id: id,
      nom: nom,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatsPer100g: fatsPer100g,
      fiberPer100g: fiberPer100g,
      sugarPer100g: sugarPer100g,
      sodiumPer100g: sodiumPer100g,
      source: 'manuel',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'brand': brand,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fats_per_100g': fatsPer100g,
      'fiber_per_100g': fiberPer100g,
      'sugar_per_100g': sugarPer100g,
      'sodium_per_100g': sodiumPer100g,
      'source': source,
      'image_url': imageUrl,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'],
      nom: map['nom'],
      brand: map['brand'],
      caloriesPer100g: _parseDouble(map['calories_per_100g']),
      proteinPer100g: _parseDouble(map['protein_per_100g']),
      carbsPer100g: _parseDouble(map['carbs_per_100g']),
      fatsPer100g: _parseDouble(map['fats_per_100g']),
      fiberPer100g: _parseDouble(map['fiber_per_100g']),
      sugarPer100g: _parseDouble(map['sugar_per_100g']),
      sodiumPer100g: _parseDouble(map['sodium_per_100g']),
      source: map['source'] ?? 'manuel',
      imageUrl: map['image_url'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
