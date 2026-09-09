// File dynamically resolving environment-specific Firebase options.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/firebase_options_dev.dart';
import 'package:durgapuja_manager/firebase_options_prod.dart';

/// Environment-aware [DefaultFirebaseOptions].
/// Resolves to [ProdFirebaseOptions] when ENV=prod, otherwise defaults to [DevFirebaseOptions].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (AppEnvironment.isProd) {
      return ProdFirebaseOptions.currentPlatform;
    }
    // DEV Firebase Options (Temporarily commented):
    // return DevFirebaseOptions.currentPlatform;
    return ProdFirebaseOptions.currentPlatform;
  }
}
