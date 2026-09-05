import 'package:dartz/dartz.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/entities/player_entity.dart';
import 'package:psa_academy/domain/repositories/player_repository.dart';

class GetAllPlayersUseCase implements UseCase<List<PlayerEntity>, NoParams> {
  final PlayerRepository repository;

  GetAllPlayersUseCase(this.repository);

  @override
  Future<Either<Failure, List<PlayerEntity>>> call(NoParams params) async {
    return await repository.getAllPlayers();
  }
}
