import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/firestore_player_datasource.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final FirestorePlayerDataSource dataSource;

  PlayerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, PlayerEntity>> getPlayerById(String playerId) async {
    try {
      final player = await dataSource.getPlayerById(playerId);
      return Right(player.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> getPlayerByUserId(String userId) async {
    try {
      final player = await dataSource.getPlayerByUserId(userId);
      return Right(player.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> createPlayer(
      PlayerEntity player) async {
    try {
      final playerModel = PlayerModel.fromEntity(player);
      final createdPlayer = await dataSource.createPlayer(playerModel);
      return Right(createdPlayer.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updatePlayer(
      PlayerEntity player) async {
    try {
      final playerModel = PlayerModel.fromEntity(player);
      final updatedPlayer = await dataSource.updatePlayer(playerModel);
      return Right(updatedPlayer.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlayer(String playerId) async {
    try {
      await dataSource.deletePlayer(playerId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers() async {
    try {
      final players = await dataSource.getAllPlayers();
      return Right(players.map((player) => player.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByCategory(
      String category) async {
    try {
      final players = await dataSource.getPlayersByCategory(category);
      return Right(players.map((player) => player.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByLevel(
      String level) async {
    try {
      final players = await dataSource.getPlayersByLevel(level);
      return Right(players.map((player) => player.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getActivePlayers() async {
    try {
      final players = await dataSource.getActivePlayers();
      return Right(players.map((player) => player.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> searchPlayersByName(
      String name) async {
    try {
      final players = await dataSource.searchPlayersByName(name);
      return Right(players.map((player) => player.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePlayerBalance(
      String playerId, double balance) async {
    try {
      await dataSource.updatePlayerBalance(playerId, balance);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAttendanceCount(
      String playerId, int count) async {
    try {
      await dataSource.updateAttendanceCount(playerId, count);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePlayerStats(
    String playerId,
    Map<String, dynamic> stats,
  ) async {
    try {
      await dataSource.updatePlayerStats(playerId, stats);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
