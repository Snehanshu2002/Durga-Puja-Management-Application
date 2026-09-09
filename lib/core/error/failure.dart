abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection issue. Please try again.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission to perform this action.']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User profile not found. Please contact administrator.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
