import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/repositories/auth_repository.dart';

class SignInUseCase implements UseCase<String, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
