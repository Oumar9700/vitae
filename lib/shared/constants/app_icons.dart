import 'package:flutter/material.dart';

/// Centralized icon constants.
/// Avoids magic strings/values scattered across the codebase.
abstract class AppIcons {
  // Navigation
  static const IconData home        = Icons.home_rounded;
  static const IconData settings    = Icons.person_rounded;
  static const IconData back        = Icons.arrow_back_ios_new_rounded;
  static const IconData close       = Icons.close_rounded;

  // Actions
  static const IconData add         = Icons.add_rounded;
  static const IconData edit        = Icons.edit_rounded;
  static const IconData delete      = Icons.delete_outline_rounded;
  static const IconData save        = Icons.check_rounded;
  static const IconData search      = Icons.search_rounded;
  static const IconData scan        = Icons.qr_code_scanner_rounded;
  static const IconData refresh     = Icons.refresh_rounded;

  // Meal / Food
  static const IconData food        = Icons.restaurant_rounded;
  static const IconData foodOutline = Icons.restaurant_outlined;
  static const IconData addMeal     = Icons.add_circle_outline_rounded;
  static const IconData batch       = Icons.playlist_add_rounded;

  // Nutrition
  static const IconData calories    = Icons.local_fire_department_rounded;
  static const IconData protein     = Icons.fitness_center_rounded;
  static const IconData info        = Icons.info_outline_rounded;
  static const IconData chart       = Icons.bar_chart_rounded;

  // Status / Feedback
  static const IconData success     = Icons.check_circle_outline_rounded;
  static const IconData warning     = Icons.warning_amber_rounded;
  static const IconData error       = Icons.error_outline_rounded;
  static const IconData offline     = Icons.wifi_off_rounded;
  static const IconData tip         = Icons.lightbulb_outline_rounded;

  // Misc
  static const IconData calendar    = Icons.calendar_today_rounded;
  static const IconData profile     = Icons.account_circle_rounded;
  static const IconData logout      = Icons.logout_rounded;
  static const IconData history     = Icons.history_rounded;
  static const IconData favorite    = Icons.favorite_rounded;
  static const IconData unit        = Icons.straighten_rounded;
}
