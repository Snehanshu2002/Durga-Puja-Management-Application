// File generated for Development Firebase Configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Development [FirebaseOptions] for durga-puja-manager-dev.
class DevFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DevFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DevFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAz0GIwQv1jPKTYkx-nbCF3mSBd_xOAsAw',
    appId: '1:967856384034:web:1c9a52047e47fcdc28827b',
    messagingSenderId: '967856384034',
    projectId: 'durga-puja-manager-dev',
    authDomain: 'durga-puja-manager-dev.firebaseapp.com',
    storageBucket: 'durga-puja-manager-dev.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-kSd2m4aJwrH3uY12bFpTACjp2mr6goc',
    appId: '1:967856384034:android:4f8f07534707be8b28827b',
    messagingSenderId: '967856384034',
    projectId: 'durga-puja-manager-dev',
    storageBucket: 'durga-puja-manager-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsRNVcjxNGaL5daIgL2liKzlYI6nMtVko',
    appId: '1:188950366932:ios:a3fd2e35f869d314c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager-dev',
    storageBucket: 'durga-puja-manager-dev.firebasestorage.app',
    iosBundleId: 'com.durgapujamanager.durgapujaManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsRNVcjxNGaL5daIgL2liKzlYI6nMtVko',
    appId: '1:188950366932:ios:a3fd2e35f869d314c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager-dev',
    storageBucket: 'durga-puja-manager-dev.firebasestorage.app',
    iosBundleId: 'com.durgapujamanager.durgapujaManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0',
    appId: '1:188950366932:web:92237bda65964a81c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager-dev',
    authDomain: 'durga-puja-manager-dev.firebaseapp.com',
    storageBucket: 'durga-puja-manager-dev.firebasestorage.app',
  );
}
