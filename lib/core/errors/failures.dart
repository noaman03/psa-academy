import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
      : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
      : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed'])
      : super(message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed'])
      : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access'])
      : super(message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String message = 'Invalid credentials'])
      : super(message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found'])
      : super(message);
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure([String message = 'Email already exists'])
      : super(message);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String message = 'Password is too weak'])
      : super(message);
}

// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Database error occurred'])
      : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
      : super(message);
}

class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure([String message = 'Resource already exists'])
      : super(message);
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([String message = 'Permission denied'])
      : super(message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed'])
      : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure([String message = 'Invalid input provided'])
      : super(message);
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage error occurred'])
      : super(message);
}

class FileUploadFailure extends Failure {
  const FileUploadFailure([String message = 'File upload failed'])
      : super(message);
}

class FileDownloadFailure extends Failure {
  const FileDownloadFailure([String message = 'File download failed'])
      : super(message);
}

// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred'])
      : super(message);
}
