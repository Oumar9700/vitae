import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimal JSON-based i18n system.
///
/// Usage in widget:
///   final tr = AppLocalizations.of(context);
///   Text(tr('common.cancel'))
///
/// Supports dot-path access and simple {placeholder} substitution:
///   tr('dashboard.score_label', {'score': '94'})
class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _strings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<void> load() async {
    final code = locale.languageCode;
    // Try exact locale, fall back to French
    try {
      final raw =
          await rootBundle.loadString('assets/i18n/translations/$code.json');
      _strings = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      final raw =
          await rootBundle.loadString('assets/i18n/translations/fr.json');
      _strings = jsonDecode(raw) as Map<String, dynamic>;
    }
  }

  /// Translates [key] (dot-path) with optional [args] for {placeholder} substitution.
  String call(String key, [Map<String, String>? args]) {
    final parts = key.split('.');
    dynamic value = _strings;
    for (final part in parts) {
      if (value is Map<String, dynamic>) {
        value = value[part];
      } else {
        return key; // key not found → return raw key as fallback
      }
    }
    if (value == null) return key;
    var result = value.toString();
    args?.forEach((k, v) => result = result.replaceAll('{$k}', v));
    return result;
  }

  /// Returns the list at [key], or empty list if not found / wrong type.
  List<String> list(String key) {
    final parts = key.split('.');
    dynamic value = _strings;
    for (final part in parts) {
      if (value is Map<String, dynamic>) {
        value = value[part];
      } else {
        return [];
      }
    }
    if (value is List) return value.cast<String>();
    return [];
  }

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final loc = AppLocalizations(locale);
    await loc.load();
    return loc;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
