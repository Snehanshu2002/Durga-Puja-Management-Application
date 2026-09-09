import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/config/app_environment.dart';
import 'package:durgapuja_manager/firebase_options_dev.dart';
import 'package:durgapuja_manager/firebase_options_prod.dart';
import 'package:durgapuja_manager/firebase_options.dart';

void main() {
  group('Firebase Environment Configuration Tests', () {
    test('Development Firebase Options target durga-puja-manager-dev', () {
      final devOptions = DevFirebaseOptions.currentPlatform;
      expect(devOptions.projectId, equals('durga-puja-manager-dev'));
      expect(devOptions.storageBucket, equals('durga-puja-manager-dev.firebasestorage.app'));
    });

    test('Production Firebase Options target durga-puja-manager', () {
      final prodOptions = ProdFirebaseOptions.currentPlatform;
      expect(prodOptions.projectId, equals('durga-puja-manager'));
      expect(prodOptions.storageBucket, equals('durga-puja-manager.firebasestorage.app'));
    });

    test('Environment parser defaults to DEV safely when empty or invalid', () {
      expect(Environment.fromString(null), equals(Environment.dev));
      expect(Environment.fromString(''), equals(Environment.dev));
      expect(Environment.fromString('invalid_env'), equals(Environment.dev));
      expect(Environment.fromString('dev'), equals(Environment.dev));
      expect(Environment.fromString('DEV'), equals(Environment.dev));
      expect(Environment.fromString('prod'), equals(Environment.prod));
      expect(Environment.fromString('production'), equals(Environment.prod));
      expect(Environment.fromString('PROD'), equals(Environment.prod));
    });

    test('DefaultFirebaseOptions returns options corresponding to active environment', () {
      final resolved = DefaultFirebaseOptions.currentPlatform;
      if (AppEnvironment.isProd) {
        expect(resolved.projectId, equals('durga-puja-manager'));
      } else {
        expect(resolved.projectId, equals('durga-puja-manager-dev'));
      }
    });
  });
}
