class AppFailure implements Exception {
  final String message;
  final String? code;

  AppFailure(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  NetworkFailure([super.message = 'Network connection failure. Please check your internet connection.']);
}

class AuthFailure extends AppFailure {
  AuthFailure([super.message = 'Authentication failed. Please log in again.']);
}

class ValidationFailure extends AppFailure {
  ValidationFailure([super.message = 'Invalid input provided.']);
}

class StorageFailure extends AppFailure {
  StorageFailure([super.message = 'Database or storage error occurred.']);
}
