import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../entities/player_entity.dart';
import '../entities/player_document_entity.dart';
import '../../core/errors/failures.dart';

abstract class PlayerRepository {
  Future<Either<Failure, PlayerEntity>> getPlayerById(String playerId);

  Future<Either<Failure, PlayerEntity>> createPlayer(PlayerEntity player);

  Future<Either<Failure, PlayerEntity>> updatePlayer(PlayerEntity player);

  Future<Either<Failure, void>> deletePlayer(String playerId);

  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers();

  Future<Either<Failure, void>> updateSessionBalance(
    String playerId, {
    required int additionalSessions,
    required double additionalAmount,
  });

  Future<Either<Failure, PlayerDocumentEntity>> uploadDocument({
    required String playerId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<Either<Failure, List<PlayerDocumentEntity>>> getPlayerDocuments(String playerId);

  Future<Either<Failure, void>> deleteDocument(String playerId, String documentId, String fileUrl);

  Stream<PlayerEntity?> watchPlayer(String playerId);
}
