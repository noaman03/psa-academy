import 'package:dartz/dartz.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
