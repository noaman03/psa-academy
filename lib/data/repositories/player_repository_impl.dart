import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/player_document_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../models/player_model.dart';
import '../models/player_document_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PlayerRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<Failure, PlayerEntity>> getPlayerById(String playerId) async {
    try {
      final doc = await _firestore.collection('players').doc(playerId).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('Player document not found.'));
      }
      return Right(PlayerModel.fromFirestore(doc));
    } catch (e) {
      return Left(FirestoreFailure('Failed to load player: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> createPlayer(PlayerEntity player) async {
    try {
      final model = PlayerModel(
        id: player.id,
        userId: player.userId,
        name: player.name,
        email: player.email,
        phone: player.phone,
        level: player.level,
        category: player.category,
        ageGroup: player.ageGroup,
        balance: player.balance,
        sessionsPaid: player.sessionsPaid,
        sessionsAttended: player.sessionsAttended,
        isAllowedPlayer: player.isAllowedPlayer,
        parentName: player.parentName,
        parentPhone: player.parentPhone,
        emergencyContact: player.emergencyContact,
        dateOfBirth: player.dateOfBirth,
        address: player.address,
        medicalInfo: player.medicalInfo,
        height: player.height,
        weight: player.weight,
        position: player.position,
        joinDate: player.joinDate,
        lastAttendance: player.lastAttendance,
        isActive: player.isActive,
      );

      await _firestore
          .collection('players')
          .doc(player.id)
          .set(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(FirestoreFailure('Failed to create player: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updatePlayer(PlayerEntity player) async {
    try {
      final model = PlayerModel(
        id: player.id,
        userId: player.userId,
        name: player.name,
        email: player.email,
        phone: player.phone,
        level: player.level,
        category: player.category,
        ageGroup: player.ageGroup,
        balance: player.balance,
        sessionsPaid: player.sessionsPaid,
        sessionsAttended: player.sessionsAttended,
        isAllowedPlayer: player.isAllowedPlayer,
        parentName: player.parentName,
        parentPhone: player.parentPhone,
        emergencyContact: player.emergencyContact,
        dateOfBirth: player.dateOfBirth,
        address: player.address,
        medicalInfo: player.medicalInfo,
        height: player.height,
        weight: player.weight,
        position: player.position,
        joinDate: player.joinDate,
        lastAttendance: player.lastAttendance,
        isActive: player.isActive,
      );

      await _firestore
          .collection('players')
          .doc(player.id)
          .update(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(FirestoreFailure('Failed to update player: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlayer(String playerId) async {
    try {
      await _firestore.collection('players').doc(playerId).delete();
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to delete player: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getAllPlayers() async {
    try {
      final snapshot = await _firestore.collection('players').get();
      final list = snapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch players: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSessionBalance(
    String playerId, {
    required int additionalSessions,
    required double additionalAmount,
  }) async {
    try {
      final playerRef = _firestore.collection('players').doc(playerId);
      final now = DateTime.now();
      final nowTimestamp = Timestamp.fromDate(now);

      await _firestore.runTransaction((transaction) async {
        final playerDoc = await transaction.get(playerRef);
        if (!playerDoc.exists) {
          throw Exception('Player not found');
        }

        final data = playerDoc.data() ?? {};
        final rawPaid = data['sessionsPaid'] ?? data['sessionPaid'] ?? 0;
        final int currentPaid = rawPaid is num ? rawPaid.toInt() : 0;
        final rawBal = data['balance'] ?? data['paymentBalance'] ?? 0;
        final double currentBal = rawBal is num ? rawBal.toDouble() : 0.0;
        final playerName = data['name'] as String? ?? 'Player';

        // Update player
        transaction.update(playerRef, {
          'sessionsPaid': currentPaid + additionalSessions,
          'balance': currentBal + additionalAmount,
          'history': FieldValue.arrayUnion([
            {
              'date': nowTimestamp,
              'type': 'payment',
              'amount': additionalAmount,
              'sessions': additionalSessions,
            }
          ]),
        });

        // Record in payments collection
        final paymentRef = _firestore.collection('payments').doc();
        transaction.set(paymentRef, {
          'playerId': playerId,
          'playerName': playerName,
          'amount': additionalAmount,
          'status': 'paid',
          'type': 'session_topup',
          'date': nowTimestamp,
          'createdAt': nowTimestamp,
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to assign payment: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerDocumentEntity>> uploadDocument({
    required String playerId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = '${timestamp}_$fileName';
      final ref = _storage
          .ref()
          .child('player_documents')
          .child(playerId)
          .child(safeName);

      final uploadTask = await ref.putData(bytes);
      final url = await uploadTask.ref.getDownloadURL();
      final now = DateTime.now();

      // Write to subcollection players/{playerId}/documents
      final docRef = _firestore
          .collection('players')
          .doc(playerId)
          .collection('documents')
          .doc();

      final model = PlayerDocumentModel(
        id: docRef.id,
        playerId: playerId,
        fileName: fileName,
        downloadUrl: url,
        fileSize: bytes.length,
        uploadDate: now,
      );

      await docRef.set(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(StorageFailure('Failed to upload document: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlayerDocumentEntity>>> getPlayerDocuments(
    String playerId,
  ) async {
    try {
      List<PlayerDocumentEntity> docs = [];

      // 1. Try subcollection
      final subSnapshot = await _firestore
          .collection('players')
          .doc(playerId)
          .collection('documents')
          .get();

      for (var doc in subSnapshot.docs) {
        docs.add(PlayerDocumentModel.fromFirestore(doc, playerId));
      }

      // 2. Legacy fallback from playerData field in main document
      final playerDoc = await _firestore.collection('players').doc(playerId).get();
      if (playerDoc.exists && playerDoc.data() != null) {
        final data = playerDoc.data()!;
        if (data['playerData'] is List) {
          final list = data['playerData'] as List;
          for (int i = 0; i < list.length; i++) {
            if (list[i] is Map<String, dynamic>) {
              docs.add(
                PlayerDocumentModel.fromMap(
                  'legacy_$i',
                  playerId,
                  list[i] as Map<String, dynamic>,
                ),
              );
            }
          }
        }
      }

      return Right(docs);
    } catch (e) {
      return Left(FirestoreFailure('Failed to load player documents: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(
    String playerId,
    String documentId,
    String fileUrl,
  ) async {
    try {
      if (!documentId.startsWith('legacy_')) {
        await _firestore
            .collection('players')
            .doc(playerId)
            .collection('documents')
            .doc(documentId)
            .delete();
      }
      if (fileUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(fileUrl).delete();
        } catch (_) {}
      }
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure('Failed to delete document: $e'));
    }
  }

  @override
  Stream<PlayerEntity?> watchPlayer(String playerId) {
    return _firestore
        .collection('players')
        .doc(playerId)
        .snapshots()
        .map((doc) => doc.exists ? PlayerModel.fromFirestore(doc) : null);
  }
}
