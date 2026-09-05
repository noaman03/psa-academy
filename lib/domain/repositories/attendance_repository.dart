import 'package:dartz/dartz.dart';
import '../entities/attendance_entity.dart';
import '../../core/errors/failures.dart';

abstract class AttendanceRepository {
  /// Get attendance by ID
  Future<Either<Failure, AttendanceEntity>> getAttendanceById(
      String attendanceId);

  /// Create attendance record
  Future<Either<Failure, AttendanceEntity>> createAttendance(
      AttendanceEntity attendance);

  /// Update attendance record
  Future<Either<Failure, AttendanceEntity>> updateAttendance(
      AttendanceEntity attendance);

  /// Delete attendance record
  Future<Either<Failure, void>> deleteAttendance(String attendanceId);

  /// Get attendance by player ID
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByPlayerId(
      String playerId);

  /// Get attendance by coach ID
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByCoachId(
      String coachId);

  /// Get attendance by date range
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get attendance by player and date range
  Future<Either<Failure, List<AttendanceEntity>>>
      getPlayerAttendanceByDateRange(
    String playerId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get unseen attendance count
  Future<Either<Failure, int>> getUnseenAttendanceCount();

  /// Mark attendance as seen
  Future<Either<Failure, void>> markAttendanceAsSeen(String attendanceId);

  /// Mark all attendance as seen
  Future<Either<Failure, void>> markAllAttendanceAsSeen();

  /// Get attendance statistics for player
  Future<Either<Failure, Map<String, dynamic>>> getPlayerAttendanceStats(
      String playerId);

  /// Stream attendance updates
  Stream<List<AttendanceEntity>> watchAttendance();

  /// Stream unseen attendance count
  Stream<int> watchUnseenCount();
}
