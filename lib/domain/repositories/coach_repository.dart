import 'package:dartz/dartz.dart';
import '../entities/coach_entity.dart';
import '../entities/coach_work_session_entity.dart';
import '../../core/errors/failures.dart';

abstract class CoachRepository {
  Future<Either<Failure, CoachEntity>> getCoachById(String coachId);

  Future<Either<Failure, CoachEntity>> createCoach(CoachEntity coach);

  Future<Either<Failure, CoachEntity>> updateCoach(CoachEntity coach);

  Future<Either<Failure, void>> deleteCoach(String coachId);

  Future<Either<Failure, List<CoachEntity>>> getAllCoaches();

  Future<Either<Failure, CoachWorkSessionEntity?>> getActiveWorkSession(String coachId);

  Future<Either<Failure, CoachWorkSessionEntity>> checkInCoach(String coachId, String coachName);

  Future<Either<Failure, CoachWorkSessionEntity>> checkOutCoach(String coachId, double hourlyRate);

  Future<Either<Failure, List<CoachWorkSessionEntity>>> getCoachWorkSessions(String coachId);
}
