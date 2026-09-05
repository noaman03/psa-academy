import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:psa_academy/core/errors/failures.dart';
import 'package:psa_academy/core/usecases/usecase.dart';
import 'package:psa_academy/domain/entities/player_entity.dart';
import 'package:psa_academy/domain/repositories/player_repository.dart';

class GetPlayerByIdUseCase
    implements UseCase<PlayerEntity, GetPlayerByIdParams> {
  final PlayerRepository repository;

  GetPlayerByIdUseCase(this.repository);

  @override
  Future<Either<Failure, PlayerEntity>> call(GetPlayerByIdParams params) async {
    return await repository.getPlayerById(params.playerId);
  }
}

class GetPlayerByIdParams extends Equatable {
  final String playerId;

  const GetPlayerByIdParams({required this.playerId});

  @override
  List<Object> get props => [playerId];
}
