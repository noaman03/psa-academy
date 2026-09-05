import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Either<Failure, AppUser>> signUpPlayer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    String? level,
    String? category,
    String? ageGroup,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AppUser?>> getCurrentUser();

  Future<Either<Failure, UserRole>> getUserRole(String uid);

  Future<Either<Failure, void>> resetPassword(String email);

  Stream<String?> watchAuthState();
}
