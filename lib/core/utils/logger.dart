import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[DEBUG]${tag != null ? ' [$tag]' : ''}: $message');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR]: $message');
      if (error != null) debugPrint('Error details: $error');
      if (stackTrace != null) debugPrint('Stack trace:\n$stackTrace');
    }
  }

  static void i(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[INFO]${tag != null ? ' [$tag]' : ''}: $message');
    }
  }
}
