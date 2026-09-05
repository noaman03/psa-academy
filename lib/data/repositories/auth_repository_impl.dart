import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, String>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userId =
          await dataSource.signInWithEmailAndPassword(email, password);
      return Right(userId);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userId =
          await dataSource.signUpWithEmailAndPassword(email, password);
      return Right(userId);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getCurrentUserId() async {
    try {
      final userId = dataSource.getCurrentUserId();
      return Right(userId);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = dataSource.isAuthenticated();
      return Right(isAuth);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await dataSource.resetPassword(email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await dataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await dataSource.deleteAccount();
      return const Right(null);
    } on Exception catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<String?> watchAuthState() {
    return dataSource.watchAuthState();
  }
}
