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

  factory FoodModel.fromOpenFoodFacts(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    return FoodModel(
      id: product['code'] ?? product['_id'] ?? '',
      nom: product['product_name_fr'] ??
          product['product_name'] ??
          product['generic_name'] ??
          'Aliment inconnu',
      brand: product['brands'],
      caloriesPer100g: _parseDouble(nutriments['energy-kcal_100g'] ??
          nutriments['energy-kcal'] ??
          nutriments['energy_100g']),
      proteinPer100g: _parseDouble(nutriments['proteins_100g']),
      carbsPer100g: _parseDouble(nutriments['carbohydrates_100g']),
      fatsPer100g: _parseDouble(nutriments['fat_100g']),
      fiberPer100g: _parseDouble(nutriments['fiber_100g']),
      sugarPer100g: _parseDouble(nutriments['sugars_100g']),
      sodiumPer100g: _parseSodium(nutriments),
      source: 'openfoods',
      imageUrl: product['image_front_url'] ?? product['image_url'],
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

  static double _parseSodium(Map<String, dynamic> nutriments) {
    // OpenFoodFacts stores salt, sodium is salt/2.5
    final sodium = nutriments['sodium_100g'];
    if (sodium != null) return _parseDouble(sodium) * 1000; // convert g to mg
    final salt = nutriments['salt_100g'];
    if (salt != null) return _parseDouble(salt) / 2.5 * 1000;
    return 0;
  }
}
