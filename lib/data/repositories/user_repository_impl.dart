import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firestore_user_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreUserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final user = await dataSource.getUserById(userId);
      return Right(user.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserByEmail(String email) async {
    try {
      final user = await dataSource.getUserByEmail(email);
      return Right(user.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await dataSource.createUser(userModel);
      return Right(createdUser.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUser = await dataSource.updateUser(userModel);
      return Right(updatedUser.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await dataSource.deleteUser(userId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsersByRole(String role) async {
    try {
      final users = await dataSource.getUsersByRole(role);
      return Right(users.map((user) => user.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final users = await dataSource.getAllUsers();
      return Right(users.map((user) => user.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> emailExists(String email) async {
    try {
      final exists = await dataSource.emailExists(email);
      return Right(exists);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserStatus(
      String userId, bool isActive) async {
    try {
      await dataSource.updateUserStatus(userId, isActive);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
