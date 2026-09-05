import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, String>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Either<Failure, String>> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user ID
  Future<Either<Failure, String?>> getCurrentUserId();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Reset password
  Future<Either<Failure, void>> resetPassword(String email);

  /// Change password
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Stream authentication state
  Stream<String?> watchAuthState();
}
