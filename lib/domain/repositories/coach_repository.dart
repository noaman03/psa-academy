import 'package:dartz/dartz.dart';
import '../entities/coach_entity.dart';
import '../../core/errors/failures.dart';

abstract class CoachRepository {
  /// Get coach by ID
  Future<Either<Failure, CoachEntity>> getCoachById(String coachId);

  /// Get coach by user ID
  Future<Either<Failure, CoachEntity>> getCoachByUserId(String userId);

  /// Create new coach
  Future<Either<Failure, CoachEntity>> createCoach(CoachEntity coach);

  /// Update existing coach
  Future<Either<Failure, CoachEntity>> updateCoach(CoachEntity coach);

  /// Delete coach
  Future<Either<Failure, void>> deleteCoach(String coachId);

  /// Get all coaches
  Future<Either<Failure, List<CoachEntity>>> getAllCoaches();

  /// Get active coaches
  Future<Either<Failure, List<CoachEntity>>> getActiveCoaches();

  /// Get coaches by specialization
  Future<Either<Failure, List<CoachEntity>>> getCoachesBySpecialization(
      String specialization);

  /// Get coaches available on specific day
  Future<Either<Failure, List<CoachEntity>>> getCoachesAvailableOn(String day);

  /// Search coaches by name
  Future<Either<Failure, List<CoachEntity>>> searchCoachesByName(String name);

  /// Update coach rating
  Future<Either<Failure, void>> updateCoachRating(
      String coachId, double rating);

  /// Update coach session count
  Future<Either<Failure, void>> updateSessionCount(String coachId, int count);
}
