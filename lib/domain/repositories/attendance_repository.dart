import 'package:dartz/dartz.dart';
import '../entities/attendance_entity.dart';
import '../../core/errors/failures.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> getAttendanceById(String attendanceId);

  Future<Either<Failure, AttendanceEntity>> recordAttendanceAtomic({
    required String coachId,
    required String coachName,
    required String playerId,
    required String type, // 'fitness' or 'recovery'
    int sessionPrice = 100,
    String? workoutId,
    String? workoutName,
    Map<String, dynamic>? workoutDetails,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByPlayerId(
    String playerId, {
    int limit = 50,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByCoachId(
    String coachId, {
    int limit = 50,
  });

  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  Stream<List<AttendanceEntity>> watchRecentAttendance({int limit = 20});
}
