import 'package:flutter/material.dart';

/// Breakpoints and responsive helpers.
/// Usage:
///   if (ResponsiveUtils.isTablet(context)) ...
///   ResponsiveUtils.paddingH(context)
abstract class ResponsiveUtils {
  // Breakpoints
  static const double _phoneMax  = 600;
  static const double _tabletMax = 1024;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _phoneMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= _phoneMax && w < _tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletMax;

  /// Horizontal padding: 16 on phones, 32 on tablets, 48 on desktop.
  static double paddingH(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  /// Safe content max-width for tablets and desktop.
  static double contentMaxWidth(BuildContext context) {
    if (isTablet(context)) return 600;
    if (isDesktop(context)) return 720;
    return double.infinity;
  }

  /// Number of columns for grids.
  static int gridCols(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Returns a widget constrained to [contentMaxWidth] and centered.
  static Widget constrained(BuildContext context, Widget child) {
    final maxW = contentMaxWidth(context);
    if (maxW == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}
