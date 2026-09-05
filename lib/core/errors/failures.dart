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
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure([super.message = 'Email already exists']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Password is too weak']);
}

// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database error occurred']);
}

typedef FirestoreFailure = DatabaseFailure;

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure([super.message = 'Resource already exists']);
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure([super.message = 'Invalid input provided']);
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

class FileUploadFailure extends Failure {
  const FileUploadFailure([super.message = 'File upload failed']);
}

class FileDownloadFailure extends Failure {
  const FileDownloadFailure([super.message = 'File download failed']);
}

// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
