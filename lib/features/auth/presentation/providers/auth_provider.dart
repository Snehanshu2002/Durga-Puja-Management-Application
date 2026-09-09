import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:durgapuja_manager/core/error/app_exception.dart';
import 'package:durgapuja_manager/features/users/domain/entities/user.dart';
import 'package:durgapuja_manager/features/users/presentation/providers/user_provider.dart';

import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/core/utils/dev_seeder.dart';
import 'session_manager_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final demoUserProvider = StateProvider<AppUser?>((ref) => null);

class AuthController {
  final FirebaseAuth _auth;
  final Ref _ref;

  AuthController(this._auth, this._ref);

  Future<void> signIn({required String email, required String password}) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw const AppException('Email and password are required.');
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      final fbUser = userCredential.user;

      if (fbUser != null) {
        if (AppEnvironment.isDev) {
          await DevBootstrapSeeder.seedDevEnvironment(fbUser);
        }

        final name = fbUser.displayName?.isNotEmpty == true
            ? fbUser.displayName!
            : _formatNameFromEmail(cleanEmail);

        try {
          await _ref.read(sessionManagerProvider).registerNewSessionOnLogin(
                uid: fbUser.uid,
                name: name,
                email: cleanEmail,
              );
        } catch (sessionErr) {
          debugPrint('Session registration warning (handled): $sessionErr');
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Signin Error Code: ${e.code}, Message: ${e.message}');
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-password') {
        throw const AppException('Incorrect email or password. Please verify your credentials or contact Admin.');
      } else if (e.code == 'operation-not-allowed') {
        throw const AppException('Email/Password sign-in is disabled in Firebase Console.');
      } else {
        throw AppException(e.message ?? 'Authentication failed (${e.code}).');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Auth Controller Signin Error: $e');
      throw AppException('Authentication failed: ${e.toString()}');
    }
    _ref.invalidate(currentUserProvider);
  }

  static String _formatNameFromEmail(String email) {
    if (email.isEmpty) return 'Super Admin';
    final prefix = email.split('@').first;
    if (prefix.toLowerCase() == 'admin') return 'Super Admin';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }

  Future<void> signOut() async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser != null) {
      await _ref.read(sessionManagerProvider).performNormalLogout(currentUser);
    } else {
      try {
        await _auth.signOut();
      } catch (_) {}
      _ref.read(demoUserProvider.notifier).state = null;
      _ref.invalidate(currentUserProvider);
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthController(auth, ref);
});
