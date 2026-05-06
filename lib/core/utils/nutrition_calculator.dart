import '../../features/authentication/domain/entities/user_profile.dart';
import '../constants/app_constants.dart';

class NutritionCalculator {
  /// Calcul du BMR (Mifflin-St Jeor)
  static double calculateBMR(UserProfile profile) {
    final base = (10 * profile.poidsKg) +
        (6.25 * profile.tailleCm) -
        (5 * profile.age);
    return profile.sexe == 'M' ? base + 5 : base - 161;
  }

  /// Calcul du TDEE = BMR × facteur activité
  static double calculateTDEE(UserProfile profile) {
    final bmr = calculateBMR(profile);
    final factor = AppConstants.activityFactors[profile.niveauActivite] ?? 1.55;
    return bmr * factor;
  }

  /// Besoin calorique journalier ajusté selon objectif
  static double calculateDailyCalories(UserProfile profile) {
    final tdee = calculateTDEE(profile);
    final diff = profile.poidsObjectifKg - profile.poidsKg;

    if (diff < 0) {
      // Perte de poids: déficit par semaine
      final deficitPerDay = (diff.abs() / profile.delaiSemaines) * 7700 / 7;
      return (tdee - deficitPerDay).clamp(1200, 4000);
    } else if (diff > 0) {
      // Prise de masse: surplus
      final surplusPerDay = (diff / profile.delaiSemaines) * 7700 / 7;
      return (tdee + surplusPerDay).clamp(1200, 5000);
    }
    return tdee;
  }

  /// Calcul des macros recommandées
  static NutritionTargets calculateTargets(UserProfile profile) {
    final calories = calculateDailyCalories(profile);

    double proteinG = profile.poidsKg * 1.8;
    double fatsG = (calories * 0.28) / 9;
    double carbsG = (calories - (proteinG * 4) - (fatsG * 9)) / 4;

    double sugarMax = AppConstants.defaultSugar;
    double sodiumMax = AppConstants.defaultSodium;

    // Ajustements conditions santé
    if (profile.conditionsSante.contains('diabete')) {
      sugarMax = 35;
      carbsG = (carbsG * 0.85).clamp(50, 300);
    }
    if (profile.conditionsSante.contains('hypertension')) {
      sodiumMax = 1500;
    }

    return NutritionTargets(
      calories: calories,
      proteinG: proteinG.clamp(50, 300),
      carbsG: carbsG.clamp(50, 500),
      fatsG: fatsG.clamp(20, 150),
      fiberMin: 25,
      sugarMax: sugarMax,
      sodiumMax: sodiumMax,
    );
  }

  /// Score nutritionnel du jour (0-100)
  static int calculateDayScore({
    required double caloriesConsumed,
    required double caloriesTarget,
    required double proteinConsumed,
    required double proteinTarget,
    required double carbsConsumed,
    required double carbsTarget,
    required double fatsConsumed,
    required double fatsTarget,
    required double sugarConsumed,
    required double sugarMax,
    required double sodiumConsumed,
    required double sodiumMax,
  }) {
    int score = 0;

    // Calories (40 pts): entre 80% et 120%
    final calRatio = caloriesConsumed / caloriesTarget;
    if (calRatio >= 0.8 && calRatio <= 1.2) score += 40;
    else if (calRatio >= 0.7 && calRatio <= 1.3) score += 25;
    else if (calRatio >= 0.6 && calRatio <= 1.4) score += 10;

    // Macros (30 pts): protéines principales
    final protRatio = proteinConsumed / proteinTarget;
    if (protRatio >= 0.8 && protRatio <= 1.3) score += 30;
    else if (protRatio >= 0.6 && protRatio <= 1.5) score += 18;
    else if (protRatio >= 0.4) score += 8;

    // Santé (30 pts): sucre + sodium
    bool sugarOk = sugarConsumed <= sugarMax;
    bool sodiumOk = sodiumConsumed <= sodiumMax;
    if (sugarOk) score += 15;
    else if (sugarConsumed <= sugarMax * 1.2) score += 8;

    if (sodiumOk) score += 15;
    else if (sodiumConsumed <= sodiumMax * 1.2) score += 8;

    return score.clamp(0, 100);
  }

  static String scoreLabel(int score) {
    if (score >= AppConstants.scoreA) return 'A';
    if (score >= AppConstants.scoreB) return 'B';
    if (score >= AppConstants.scoreC) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

class NutritionTargets {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final double fiberMin;
  final double sugarMax;
  final double sodiumMax;

  const NutritionTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.fiberMin,
    required this.sugarMax,
    required this.sodiumMax,
  });
}
