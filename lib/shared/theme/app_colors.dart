import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary - Vert naturel santé
  static const Color primary = Color(0xFF27AE60);
  static const Color primaryDark = Color(0xFF1E8449);
  static const Color primaryLight = Color(0xFFA9DFBF);
  static const Color primaryPale = Color(0xFFD5F4E6);

  // Accent - Orange confiance
  static const Color accent = Color(0xFFF39C12);
  static const Color accentDark = Color(0xFFC17C1B);
  static const Color accentLight = Color(0xFFFCE5CD);

  // Alerts - Rouge soft
  static const Color error = Color(0xFFE74C3C);
  static const Color errorDark = Color(0xFFA93226);
  static const Color errorLight = Color(0xFFFADBD8);

  // Neutrals
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF95A5A6);
  static const Color textTertiary = Color(0xFFBDC3C7);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECEFF1);
  static const Color divider = Color(0xFFEEEEEE);

  // Charts (macros)
  static const Color chartProtein = Color(0xFF3498DB);
  static const Color chartCarbs = Color(0xFFF39C12);
  static const Color chartFats = Color(0xFFE74C3C);
  static const Color chartFiber = Color(0xFF27AE60);

  // Nutrition status
  static const Color nutritionGood = Color(0xFF27AE60);
  static const Color nutritionWarning = Color(0xFFF39C12);
  static const Color nutritionBad = Color(0xFFE74C3C);

  // Character states
  static const Color charHappy = Color(0xFF27AE60);
  static const Color charWarning = Color(0xFFF39C12);
  static const Color charSad = Color(0xFFE74C3C);
  static const Color charNeutral = Color(0xFFECEFF1);

  // Shadow
  static const Color shadow = Color(0x1A2C3E50);
}
