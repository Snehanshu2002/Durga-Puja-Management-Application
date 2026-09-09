// File generated for Production Firebase Configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Production [FirebaseOptions] for durga-puja-manager.
class ProdFirebaseOptions {
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
          'ProdFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'ProdFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0',
    appId: '1:188950366932:web:5ed1437d9521cd7cc40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager',
    authDomain: 'durga-puja-manager.firebaseapp.com',
    storageBucket: 'durga-puja-manager.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOOTiqQy-GUQ_b91TZeuOjAw3GVZ9Mndg',
    appId: '1:188950366932:android:a8606e8703e68f8bc40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager',
    storageBucket: 'durga-puja-manager.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsRNVcjxNGaL5daIgL2liKzlYI6nMtVko',
    appId: '1:188950366932:ios:a3fd2e35f869d314c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager',
    storageBucket: 'durga-puja-manager.firebasestorage.app',
    iosBundleId: 'com.durgapujamanager.durgapujaManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsRNVcjxNGaL5daIgL2liKzlYI6nMtVko',
    appId: '1:188950366932:ios:a3fd2e35f869d314c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager',
    storageBucket: 'durga-puja-manager.firebasestorage.app',
    iosBundleId: 'com.durgapujamanager.durgapujaManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0',
    appId: '1:188950366932:web:92237bda65964a81c40941',
    messagingSenderId: '188950366932',
    projectId: 'durga-puja-manager',
    authDomain: 'durga-puja-manager.firebaseapp.com',
    storageBucket: 'durga-puja-manager.firebasestorage.app',
  );
}
