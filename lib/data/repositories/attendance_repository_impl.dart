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
    try {
      final playerRef = _firestore.collection('players').doc(playerId);
      final attendanceRef = _firestore.collection('attendance').doc();
      final now = DateTime.now();
      final nowTimestamp = Timestamp.fromDate(now);

      AttendanceModel? createdRecord;

      await _firestore.runTransaction((transaction) async {
        final playerDoc = await transaction.get(playerRef);
        if (!playerDoc.exists) {
          throw Exception('Player does not exist in academy database.');
        }

        final data = playerDoc.data() ?? {};
        final playerName = data['name'] as String? ?? 'Player';

        // Safe sessions reading
        final rawPaid = data['sessionsPaid'] ?? data['sessionPaid'] ?? 0;
        final int sessionsPaid = rawPaid is num ? rawPaid.toInt() : 0;

        final rawAttended = data['sessionsAttended'] ?? 0;
        final int sessionsAttended =
            rawAttended is num ? rawAttended.toInt() : 0;

        final bool isAllowed = data['isAllowedPlayer'] as bool? ?? true;
        if (!isAllowed) {
          throw Exception('Player account is suspended.');
        }
        final rawBalance = data['balance'] ?? data['paymentBalance'] ?? 0;
        final double currentBalance =
            rawBalance is num ? rawBalance.toDouble() : 0.0;

        final int newAttended = sessionsAttended + 1;
        final double newBalance = currentBalance - sessionPrice;

        // Atomic Player update
        transaction.update(playerRef, {
          'sessionsAttended': newAttended,
          'balance': newBalance,
          'lastAttendance': nowTimestamp,
          'history': FieldValue.arrayUnion([
            {
              'date': nowTimestamp,
              'type': type == 'recovery' ? 'recovery attendance' : 'fitness attendance',
              'coachId': coachId,
              'coachName': coachName,
            }
          ]),
        });

        // Atomic Attendance Record creation
        final attendanceData = {
          'playerId': playerId,
          'playerName': playerName,
          'coachId': coachId,
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

        // If sessions are negative, record debit payment entry
        if (sessionsPaid < newAttended) {
          final paymentRef = _firestore.collection('payments').doc();
          transaction.set(paymentRef, {
            'playerId': playerId,
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
      return Left(FirestoreFailure('Failed to record attendance: $e'));
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
