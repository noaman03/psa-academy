import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseFirestore _firestore;

  AttendanceRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, AttendanceEntity>> getAttendanceById(
    String attendanceId,
  ) async {
    try {
      final doc = await _firestore.collection('attendance').doc(attendanceId).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('Attendance record not found.'));
      }
      return Right(AttendanceModel.fromFirestore(doc));
    } catch (e) {
      return Left(FirestoreFailure('Failed to get attendance: $e'));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> recordAttendanceAtomic({
    required String coachId,
    required String coachName,
    required String playerId,
    required String type,
    int sessionPrice = 100,
    String? workoutId,
    String? workoutName,
    Map<String, dynamic>? workoutDetails,
  }) async {
    // 1. Strict identity and parameter validation
    final trimmedCoachId = coachId.trim();
    final trimmedPlayerId = playerId.trim();
    if (trimmedCoachId.isEmpty) {
      return const Left(ValidationFailure('Coach ID cannot be empty.'));
    }
    if (trimmedPlayerId.isEmpty) {
      return const Left(ValidationFailure('Player ID cannot be empty.'));
    }
    if (trimmedCoachId == trimmedPlayerId) {
      return const Left(ValidationFailure(
          'Coach ID and Player ID cannot be identical. A coach cannot check in for themselves as a player.'));
    }
    if (type != 'fitness' && type != 'recovery') {
      return const Left(ValidationFailure(
          'Invalid attendance type. Must be "fitness" or "recovery".'));
    }

    String? validationError;

    try {
      final playerRef = _firestore.collection('players').doc(trimmedPlayerId);
      final attendanceRef = _firestore.collection('attendance').doc();
      final now = DateTime.now();
      final nowTimestamp = Timestamp.fromDate(now);

      AttendanceModel? createdRecord;

      await _firestore.runTransaction((transaction) async {
        final playerDoc = await transaction.get(playerRef);
        if (!playerDoc.exists) {
          validationError = 'Player does not exist in academy database.';
          throw Exception(validationError);
        }

        final data = playerDoc.data() ?? {};
        final playerName = data['name'] as String? ?? 'Player';

        final bool isActive = data['isActive'] as bool? ?? true;
        if (!isActive) {
          validationError = 'Player account is currently deactivated.';
          throw Exception(validationError);
        }

        final bool isAllowed = data['isAllowedPlayer'] as bool? ?? true;

        // Canonical Session Accounting
        final int schemaVersion = (data['schemaVersion'] as num?)?.toInt() ?? 1;
        final rawPaid = data['sessionsPaid'] ?? data['sessionPaid'] ?? 0;
        final int rawPaidInt = rawPaid is num ? rawPaid.toInt() : 0;
        final rawAttended = data['sessionsAttended'] ?? 0;
        final int currentAttended =
            rawAttended is num ? rawAttended.toInt() : 0;

        // In legacy schema, sessionsPaid was decremented on attendance.
        // If schemaVersion < 2, total lifetime paid is rawPaidInt + currentAttended.
        final int totalLifetimePaid = schemaVersion >= 2
            ? rawPaidInt
            : (rawPaidInt + currentAttended);

        final int remainingBeforeCheckIn = totalLifetimePaid - currentAttended;

        // Overdraft validation
        if (remainingBeforeCheckIn <= 0 && !isAllowed) {
          validationError =
              'Player has 0 remaining sessions and is not authorized for overdraft check-in.';
          throw Exception(validationError);
        }

        // Duplicate attendance check: within 15 minutes
        final lastAttTimestamp = data['lastAttendance'] as Timestamp?;
        if (lastAttTimestamp != null) {
          final diff = now.difference(lastAttTimestamp.toDate());
          if (diff.inMinutes < 15 && diff.inMinutes >= 0) {
            validationError =
                'Duplicate check-in detected. Player already checked in ${diff.inMinutes} minute(s) ago.';
            throw Exception(validationError);
          }
        }

        final rawBalance = data['balance'] ?? data['paymentBalance'] ?? 0;
        final double currentBalance =
            rawBalance is num ? rawBalance.toDouble() : 0.0;

        final int newAttended = currentAttended + 1;
        final double newBalance = currentBalance - sessionPrice;

        // Atomic Player update
        transaction.update(playerRef, {
          'schemaVersion': 2,
          'sessionsPaid': totalLifetimePaid,
          'sessionsAttended': newAttended,
          'balance': newBalance,
          'lastAttendance': nowTimestamp,
          'history': FieldValue.arrayUnion([
            {
              'date': nowTimestamp,
              'type': type == 'recovery'
                  ? 'recovery attendance'
                  : 'fitness attendance',
              'coachId': trimmedCoachId,
              'coachName': coachName,
            }
          ]),
        });

        // Atomic Attendance Record creation
        final attendanceData = {
          'playerId': trimmedPlayerId,
          'playerName': playerName,
          'coachId': trimmedCoachId,
          'coachName': coachName,
          'type': type,
          'status': 'present',
          'date': nowTimestamp,
          if (workoutId != null) 'workoutId': workoutId,
          if (workoutName != null) 'workoutName': workoutName,
          if (workoutDetails != null) 'workoutDetails': workoutDetails,
          'isSeen': false,
          'createdAt': nowTimestamp,
        };

        transaction.set(attendanceRef, attendanceData);

        // If sessions are overdraft/negative, record debit payment entry
        if (totalLifetimePaid < newAttended) {
          final paymentRef = _firestore.collection('payments').doc();
          transaction.set(paymentRef, {
            'playerId': trimmedPlayerId,
            'playerName': playerName,
            'amount': sessionPrice.toDouble(),
            'status': 'debit',
            'type': type,
            'date': nowTimestamp,
            'createdAt': nowTimestamp,
          });
        }

        createdRecord = AttendanceModel(
          id: attendanceRef.id,
          playerId: playerId,
          playerName: playerName,
          coachId: coachId,
          coachName: coachName,
          type: type,
          status: 'present',
          date: now,
          workoutId: workoutId,
          workoutName: workoutName,
          workoutDetails: workoutDetails,
          isSeen: false,
          createdAt: now,
        );
      });

      if (createdRecord != null) {
        return Right(createdRecord!);
      }
      return const Left(FirestoreFailure('Transaction finished without record.'));
    } catch (e) {
      if (validationError != null) {
        return Left(FirestoreFailure(validationError!));
      }
      dynamic errorObj = e;
      String message = e.toString();
      try {
        if (errorObj.error != null) {
          message = errorObj.error.toString();
        }
      } catch (_) {}
      message = message.replaceFirst('Exception: ', '');
      return Left(FirestoreFailure('Failed to record attendance: $message'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByPlayerId(
    String playerId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('playerId', isEqualTo: playerId)
          .limit(limit)
          .get();

      final list = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch player attendance: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByCoachId(
    String coachId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('coachId', isEqualTo: coachId)
          .limit(limit)
          .get();

      final list = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch coach attendance: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final list = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch attendance by date: $e'));
    }
  }

  @override
  Stream<List<AttendanceEntity>> watchRecentAttendance({int limit = 20}) {
    return _firestore
        .collection('attendance')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return items;
    });
  }
}
