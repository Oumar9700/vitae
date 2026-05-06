# Vitae — Ton Journal Nutritionnel Intelligent

> Application mobile Flutter de suivi nutritionnel avec personnage animé et calculs personnalisés BMR/TDEE.

---

## Stack Technique

| Couche | Technologie |
|--------|-------------|
| Framework | Flutter 3.x + Dart |
| Architecture | Clean Architecture (Data / Domain / Presentation) |
| State Management | BLoC (flutter_bloc 8.x) |
| Injection | GetIt |
| Navigation | GoRouter |
| Backend | Firebase (Firestore + Auth) |
| API Aliments | OpenFoodFacts (gratuit, 400k+ aliments) |
| Stockage local | SharedPreferences + flutter_secure_storage |

---

## Configuration Initiale (Obligatoire)

### 1. Prérequis

```bash
flutter doctor
dart pub global activate flutterfire_cli
```

### 2. Créer un Projet Firebase

1. Va sur [console.firebase.google.com](https://console.firebase.google.com)
2. Crée un projet (ex: `vitae-app`)
3. Active **Authentication** → Email/Password
4. Active **Cloud Firestore** → Mode production

### 3. Connecter Firebase

```bash
# Depuis la racine du projet vitae/
flutterfire configure --project=TON-PROJET-ID
```

Cela génère automatiquement `lib/firebase_options.dart`.

### 4. Règles Firestore

Dans Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /users/{userId}/meals/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### 5. Lancer l'application

```bash
flutter pub get
flutter run
```

---

## Architecture du Projet

```
lib/
├── main.dart                         # Entry point
├── firebase_options.dart             # Config Firebase (généré)
├── di/injection_container.dart       # GetIt - injection dépendances
│
├── core/
│   ├── constants/app_constants.dart  # Constantes (calories, unités, repas...)
│   ├── error/                        # Failures + Exceptions
│   └── utils/
│       ├── nutrition_calculator.dart # BMR / TDEE / macros / score
│       └── validators.dart           # Validation formulaires
│
├── features/
│   ├── authentication/               # Login + Signup 5 étapes
│   │   ├── data/                     # Firebase Auth datasource
│   │   ├── domain/                   # UserProfile entity + AuthRepository
│   │   └── presentation/             # AuthBloc + LoginPage + SignupPage
│   │
│   ├── meal_tracking/                # Feature principale
│   │   ├── data/                     # Firestore + OpenFoodFacts + LocalCache
│   │   ├── domain/                   # Food, MealEntry, Nutrition, MealRepository
│   │   └── presentation/
│   │       ├── bloc/                 # MealBloc (events/states)
│   │       ├── pages/                # Dashboard, ManualInput, Edit, Analytics
│   │       └── widgets/              # Character, NutritionBars, MealCard
│   │
│   └── settings/                     # Profil + Besoins nutritionnels calculés
│
└── shared/
    ├── theme/                        # AppColors + AppTypography + AppTheme
    ├── widgets/                      # PrimaryButton, VitaeTextField
    ├── extensions/                   # DateExtensions, NumExtensions
    └── services/app_router.dart      # GoRouter configuration
```

---

## Fonctionnalités Phase 1

- ✅ **Auth** — Login + Signup 5 étapes + Reset password
- ✅ **Onboarding** — Profil complet (sexe, âge, poids, taille, objectifs, santé)
- ✅ **Calculs** — BMR (Mifflin-St Jeor), TDEE, macros + ajustements conditions
- ✅ **Dashboard** — Personnage animé + Progress calories + Barres macros
- ✅ **Saisie manuelle** — Recherche OpenFoodFacts (debounced autocomplete)
- ✅ **Édition** — Modal avec recalcul nutrition temps réel
- ✅ **Suppression** — Swipe-to-delete + undo snackbar
- ✅ **Analytics** — Score A-F + Détails + Conseils personnalisés
- ✅ **Historique** — Navigation jour précédent/suivant
- ✅ **Sync cloud** — Firestore listeners temps réel

---

## Palette Couleurs

| Rôle | Couleur |
|------|---------|
| Primaire (santé) | `#27AE60` vert |
| Accent (attention) | `#F39C12` orange |
| Erreur (surplus) | `#E74C3C` rouge |
| Texte principal | `#2C3E50` |
| Background cards | `#F8F9FA` |

---

## Commandes

```bash
flutter pub get          # Dépendances
flutter run              # Debug
flutter build apk        # Release Android
flutter build ios        # Release iOS
dart analyze lib/        # Analyse statique
```

---

## Phases Suivantes

| Phase | Features |
|-------|----------|
| Phase 2 | Photo (Google ML Kit) + Voix (speech_to_text) |
| Phase 3 | Analytics 7/30/90j + Graphiques FL Chart |
| Phase 4 | Gamification + Badges + Notifications push |
