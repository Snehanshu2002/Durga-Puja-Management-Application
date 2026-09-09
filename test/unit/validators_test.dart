import 'package:flutter_test/flutter_test.dart';
import 'package:durgapuja_manager/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Email validation returns null for valid email', () {
      expect(Validators.validateEmail('admin@durgapuja.org'), isNull);
      expect(Validators.validateEmail('user.test@domain.co.in'), isNull);
    });

    test('Email validation returns error message for invalid email', () {
      expect(Validators.validateEmail(''), 'Email is required.');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address.');
      expect(Validators.validateEmail('admin@domain'), 'Please enter a valid email address.');
    });

    test('Password validation returns null for 6+ characters', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('secure_pass_123'), isNull);
    });

    test('Password validation returns error message for short password', () {
      expect(Validators.validatePassword(''), 'Password is required.');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters.');
    });
  });
}
