import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionIdKey = 'active_session_id';

  /// Fetch local session ID stored on device.
  Future<String?> getLocalSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_sessionIdKey);
    } catch (e) {
      debugPrint('Error reading local session ID: $e');
      return null;
    }
  }

  /// Save session ID locally on device.
  Future<void> saveLocalSessionId(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionIdKey, sessionId);
    } catch (e) {
      debugPrint('Error saving local session ID: $e');
    }
  }

  /// Clear local session ID from device storage.
  Future<void> clearLocalSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionIdKey);
    } catch (e) {
      debugPrint('Error clearing local session ID: $e');
    }
  }

  /// Generate a cryptographically random, unique session ID.
  String generateSecureSessionId() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final hexString = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'sess_${timestamp}_$hexString';
  }

  /// Platform detection without using `dart:io` for Web + Android WebView safety.
  String getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }
}
