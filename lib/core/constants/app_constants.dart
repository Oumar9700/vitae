abstract class AppConstants {
  // App
  static const String appName = 'Vitae';
  static const String appTagline = 'Ton Journal Nutritionnel Intelligent';

  // OpenFoodFacts — configuration gérée par le SDK officiel (openfoodfacts package)
  // Pays : France · Langue : Français · API v3

  // Nutrition defaults (si non connecté)
  static const int defaultCalories = 2000;
  static const double defaultProtein = 150;
  static const double defaultCarbs = 250;
  static const double defaultFats = 67;
  static const double defaultFiber = 25;
  static const double defaultSugar = 50;
  static const double defaultSodium = 2300;

  // Activity multipliers (Mifflin-St Jeor)
  static const Map<String, double> activityFactors = {
    'sedentaire': 1.2,
    'leger': 1.375,
    'modere': 1.55,
    'actif': 1.725,
    'tres_actif': 1.9,
  };

  // Validation
  static const int passwordMinLength = 8;
  static const int ageMin = 13;
  static const int ageMax = 120;
  static const double weightMin = 30;
  static const double weightMax = 300;
  static const int heightMin = 100;
  static const int heightMax = 250;
  static const int weeksMin = 4;
  static const int weeksMax = 52;
  static const double quantityMin = 1;
  static const double quantityMax = 5000;

  // Nutrition score thresholds
  static const int scoreA = 90;
  static const int scoreB = 80;
  static const int scoreC = 70;

  // Storage keys
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyOnboardingDone = 'onboarding_done';

  // Meal types
  static const List<String> mealTypes = [
    'petit_dejeuner',
    'dejeuner',
    'gouter',
    'diner',
    'snack',
  ];

  static const Map<String, String> mealTypeLabels = {
    'petit_dejeuner': 'Petit-Déjeuner',
    'dejeuner': 'Déjeuner',
    'gouter': 'Goûter',
    'diner': 'Dîner',
    'snack': 'Snack',
  };

  static const Map<String, String> mealTypeEmojis = {
    'petit_dejeuner': '🌅',
    'dejeuner': '🍽️',
    'gouter': '☕',
    'diner': '🌙',
    'snack': '🍎',
  };

  // Units
  static const List<String> foodUnits = [
    'g', 'ml', 'tranche', 'portion', 'bol', 'verre', 'tasse',
    'cuillère à soupe', 'cuillère à café',
  ];

  // Conversions en grammes pour chaque unité (valeurs de référence)
  static const Map<String, double> unitToGrams = {
    'g': 1.0,
    'ml': 1.0,       // approximation (eau ≈ 1g/ml)
    'tranche': 28.0, // tranche pain/charcuterie ≈ 25-30g
    'portion': 150.0,
    'bol': 250.0,
    'verre': 200.0,
    'tasse': 240.0,
    'cuillère à soupe': 15.0,
    'cuillère à café': 5.0,
  };

  // Network (Firestore / autres appels HTTP internes)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Cache
  static const int favoriteFoodsMax = 10;
  static const int recentFoodsMax = 20;
}
