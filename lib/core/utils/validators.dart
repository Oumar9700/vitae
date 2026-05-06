import '../constants/app_constants.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < AppConstants.passwordMinLength) {
      return 'Minimum ${AppConstants.passwordMinLength} caractères';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Doit contenir une majuscule';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Doit contenir une minuscule';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Doit contenir un chiffre';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != password) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  static String? required(String? value, [String fieldName = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) return '$fieldName est requis';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.isEmpty) return 'Âge requis';
    final age = int.tryParse(value);
    if (age == null) return 'Âge invalide';
    if (age < AppConstants.ageMin || age > AppConstants.ageMax) {
      return 'Âge entre ${AppConstants.ageMin} et ${AppConstants.ageMax}';
    }
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.isEmpty) return 'Poids requis';
    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null) return 'Poids invalide';
    if (weight < AppConstants.weightMin || weight > AppConstants.weightMax) {
      return 'Poids entre ${AppConstants.weightMin} et ${AppConstants.weightMax} kg';
    }
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.isEmpty) return 'Taille requise';
    final height = int.tryParse(value);
    if (height == null) return 'Taille invalide';
    if (height < AppConstants.heightMin || height > AppConstants.heightMax) {
      return 'Taille entre ${AppConstants.heightMin} et ${AppConstants.heightMax} cm';
    }
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.isEmpty) return 'Quantité requise';
    final qty = double.tryParse(value.replaceAll(',', '.'));
    if (qty == null) return 'Quantité invalide';
    if (qty < AppConstants.quantityMin || qty > AppConstants.quantityMax) {
      return 'Entre ${AppConstants.quantityMin.toInt()} et ${AppConstants.quantityMax.toInt()}';
    }
    return null;
  }

  static int passwordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;
    return strength;
  }
}
