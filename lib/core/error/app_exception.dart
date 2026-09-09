class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class UserNotFoundException extends AppException {
  // ignore: use_super_parameters
  const UserNotFoundException([
    String message = 'User profile not found. Please contact administrator.',
    String? code,
  ]) : super(message, code: code);
}

class UserInactiveException extends AppException {
  // ignore: use_super_parameters
  const UserInactiveException([
    String message = 'Your account is currently inactive. Please contact the administrator.',
    String? code,
  ]) : super(message, code: code);
}

class NetworkException extends AppException {
  // ignore: use_super_parameters
  const NetworkException([
    String message = 'Network error occurred. Please check your internet connection.',
    String? code,
  ]) : super(message, code: code);
}

class PermissionException extends AppException {
  // ignore: use_super_parameters
  const PermissionException([
    String message = 'Permission denied.',
    String? code,
  ]) : super(message, code: code);
}
