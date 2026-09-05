import 'package:dartz/dartz.dart';
import '../entities/player_entity.dart';
import '../../core/errors/failures.dart';

abstract class PlayerRepository {
  /// Get player by ID
  Future<Either<Failure, PlayerEntity>> getPlayerById(String playerId);

  /// Get player by user ID
  Future<Either<Failure, PlayerEntity>> getPlayerByUserId(String userId);

  /// Create new player
  Future<Either<Failure, PlayerEntity>> createPlayer(PlayerEntity player);

  /// Update existing player
  Future<Either<Failure, PlayerEntity>> updatePlayer(PlayerEntity player);

  /// Delete player
  Future<Either<Failure, void>> deletePlayer(String playerId);

  /// Get all players
  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers();

  /// Get players by category
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByCategory(
      String category);

  /// Get players by level
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByLevel(String level);

  /// Get active players
  Future<Either<Failure, List<PlayerEntity>>> getActivePlayers();

  /// Search players by name
  Future<Either<Failure, List<PlayerEntity>>> searchPlayersByName(String name);

  /// Update player balance
  Future<Either<Failure, void>> updatePlayerBalance(
      String playerId, double balance);

  /// Update player attendance count
  Future<Either<Failure, void>> updateAttendanceCount(
      String playerId, int count);

  /// Update player stats
  Future<Either<Failure, void>> updatePlayerStats(
      String playerId, Map<String, dynamic> stats);
}
