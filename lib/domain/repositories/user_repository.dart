import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class UserRepository {
  /// Get user by ID
  Future<Either<Failure, UserEntity>> getUserById(String userId);

  /// Get user by email
  Future<Either<Failure, UserEntity>> getUserByEmail(String email);

  /// Create new user
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);

  /// Update existing user
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  /// Delete user
  Future<Either<Failure, void>> deleteUser(String userId);

  /// Get all users by role
  Future<Either<Failure, List<UserEntity>>> getUsersByRole(String role);

  /// Get all users
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  /// Check if email exists
  Future<Either<Failure, bool>> emailExists(String email);

  /// Update user status
  Future<Either<Failure, void>> updateUserStatus(String userId, bool isActive);
}
