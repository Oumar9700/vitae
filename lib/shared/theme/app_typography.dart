import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // H1 - Display, 1x par écran
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    height: 1.27,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // H2 - Page titles
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.24,
  );

  // H3 - Section titles
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    height: 1.44,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.18,
  );

  // Body - Contenu principal
  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Body Medium
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Label - Labels, hints
  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Caption - Dates, captions
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.32,
  );

  // Calorie number (big display)
  static const TextStyle calorieDisplay = TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Score badge
  static const TextStyle scoreBadge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
