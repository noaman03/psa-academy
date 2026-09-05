import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/firestore_attendance_datasource.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirestoreAttendanceDataSource dataSource;

  AttendanceRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AttendanceEntity>> getAttendanceById(
      String attendanceId) async {
    try {
      final attendance = await dataSource.getAttendanceById(attendanceId);
      return Right(attendance.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> createAttendance(
      AttendanceEntity attendance) async {
    try {
      final attendanceModel = AttendanceModel.fromEntity(attendance);
      final created = await dataSource.createAttendance(attendanceModel);
      return Right(created.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> updateAttendance(
      AttendanceEntity attendance) async {
    try {
      final attendanceModel = AttendanceModel.fromEntity(attendance);
      final updated = await dataSource.updateAttendance(attendanceModel);
      return Right(updated.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttendance(String attendanceId) async {
    try {
      await dataSource.deleteAttendance(attendanceId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByPlayerId(
    String playerId,
  ) async {
    try {
      final attendance = await dataSource.getAttendanceByPlayerId(playerId);
      return Right(attendance.map((a) => a.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByCoachId(
    String coachId,
  ) async {
    try {
      final attendance = await dataSource.getAttendanceByCoachId(coachId);
      return Right(attendance.map((a) => a.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final attendance =
          await dataSource.getAttendanceByDateRange(startDate, endDate);
      return Right(attendance.map((a) => a.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>>
      getPlayerAttendanceByDateRange(
    String playerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final attendance = await dataSource.getPlayerAttendanceByDateRange(
        playerId,
        startDate,
        endDate,
      );
      return Right(attendance.map((a) => a.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnseenAttendanceCount() async {
    try {
      final count = await dataSource.getUnseenAttendanceCount();
      return Right(count);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAttendanceAsSeen(
      String attendanceId) async {
    try {
      await dataSource.markAttendanceAsSeen(attendanceId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAttendanceAsSeen() async {
    try {
      await dataSource.markAllAttendanceAsSeen();
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPlayerAttendanceStats(
    String playerId,
  ) async {
    try {
      // Get all attendance for the player
      final attendance = await dataSource.getAttendanceByPlayerId(playerId);

      // Calculate statistics
      final total = attendance.length;
      final present = attendance.where((a) => a.status == 'present').length;
      final absent = attendance.where((a) => a.status == 'absent').length;
      final late = attendance.where((a) => a.status == 'late').length;
      final excused = attendance.where((a) => a.status == 'excused').length;

      final attendanceRate = total > 0 ? (present / total * 100) : 0.0;

      return Right({
        'total': total,
        'present': present,
        'absent': absent,
        'late': late,
        'excused': excused,
        'attendanceRate': attendanceRate,
      });
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<AttendanceEntity>> watchAttendance() {
    return dataSource.watchAttendance().map(
          (attendance) => attendance.map((a) => a.toEntity()).toList(),
        );
  }

  @override
  Stream<int> watchUnseenCount() {
    return dataSource.watchUnseenCount();
  }
}
