import 'package:equatable/equatable.dart';

class Food extends Equatable {
  final String id;
  final String nom;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double sodiumPer100g; // en mg
  final String source; // 'openfoods', 'usda', 'manuel'
  final String? imageUrl;

  const Food({
    required this.id,
    required this.nom,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.fiberPer100g = 0,
    this.sugarPer100g = 0,
    this.sodiumPer100g = 0,
    this.source = 'openfoods',
    this.imageUrl,
  });

  Nutrition nutritionForQuantity(double quantityG) {
    final ratio = quantityG / 100;
    return Nutrition(
      calories: caloriesPer100g * ratio,
      proteinG: proteinPer100g * ratio,
      carbsG: carbsPer100g * ratio,
      fatsG: fatsPer100g * ratio,
      fiberG: fiberPer100g * ratio,
      sugarG: sugarPer100g * ratio,
      sodiumMg: sodiumPer100g * ratio,
    );
  }

  @override
  List<Object?> get props => [id, nom, caloriesPer100g];
}

class Nutrition extends Equatable {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;

  const Nutrition({
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatsG = 0,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
  });

  Nutrition operator +(Nutrition other) => Nutrition(
        calories: calories + other.calories,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatsG: fatsG + other.fatsG,
        fiberG: fiberG + other.fiberG,
        sugarG: sugarG + other.sugarG,
        sodiumMg: sodiumMg + other.sodiumMg,
      );

  static const Nutrition zero = Nutrition();

  @override
  List<Object?> get props => [calories, proteinG, carbsG, fatsG];
}
