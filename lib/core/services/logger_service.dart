import 'package:flutter/foundation.dart';

/// Centralized logger — only prints in debug mode.
/// Usage: AppLogger.d('message'), AppLogger.e('error', error, stackTrace)
abstract class AppLogger {
  static void d(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[DEBUG]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void i(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[INFO]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void w(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[WARN]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void e(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      debugPrint('[ERROR]${tag != null ? '[$tag]' : ''} $message');
      if (error != null) debugPrint('  └─ $error');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace, maxFrames: 8);
    }
  }
}
