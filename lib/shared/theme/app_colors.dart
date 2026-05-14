import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary — Indigo moderne
  static const Color primary      = Color(0xFF6366F1);
  static const Color primaryDark  = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color primaryPale  = Color(0xFFEEF2FF);

  // Accent — Teal énergie
  static const Color accent      = Color(0xFF14B8A6);
  static const Color accentDark  = Color(0xFF0F766E);
  static const Color accentLight = Color(0xFF99F6E4);
  static const Color accentPale  = Color(0xFFF0FDFA);

  // Alerts — Rouge soft
  static const Color error      = Color(0xFFEF4444);
  static const Color errorDark  = Color(0xFFB91C1C);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Warning
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Neutrals
  static const Color textPrimary   = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary  = Color(0xFFD1D5DB);
  static const Color bgLight       = Color(0xFFF8FAFC);
  static const Color bgWhite       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE5E7EB);
  static const Color divider       = Color(0xFFF3F4F6);

  // Charts (macros)
  static const Color chartProtein = Color(0xFF6366F1); // Indigo — protéines
  static const Color chartCarbs   = Color(0xFF14B8A6); // Teal — glucides
  static const Color chartFats    = Color(0xFFF59E0B); // Amber — lipides
  static const Color chartFiber   = Color(0xFF10B981); // Emerald — fibres

  // Nutrition status
  static const Color nutritionGood    = Color(0xFF10B981);
  static const Color nutritionWarning = Color(0xFFF59E0B);
  static const Color nutritionBad     = Color(0xFFEF4444);

  // Character states
  static const Color charHappy   = Color(0xFF10B981);
  static const Color charWarning = Color(0xFFF59E0B);
  static const Color charSad     = Color(0xFFEF4444);
  static const Color charNeutral = Color(0xFFE5E7EB);

  // Shadow
  static const Color shadow = Color(0x1A1E1B4B);
}
