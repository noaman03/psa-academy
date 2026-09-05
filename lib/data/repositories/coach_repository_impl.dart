import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/repositories/coach_repository.dart';
import '../datasources/firestore_coach_datasource.dart';
import '../models/coach_model.dart';

class CoachRepositoryImpl implements CoachRepository {
  final FirestoreCoachDataSource dataSource;

  CoachRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, CoachEntity>> getCoachById(String coachId) async {
    try {
      final coach = await dataSource.getCoachById(coachId);
      return Right(coach.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> getCoachByUserId(String userId) async {
    try {
      final coach = await dataSource.getCoachByUserId(userId);
      return Right(coach.toEntity());
    } on Exception catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> createCoach(CoachEntity coach) async {
    try {
      final coachModel = CoachModel.fromEntity(coach);
      final created = await dataSource.createCoach(coachModel);
      return Right(created.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> updateCoach(CoachEntity coach) async {
    try {
      final coachModel = CoachModel.fromEntity(coach);
      final updated = await dataSource.updateCoach(coachModel);
      return Right(updated.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoach(String coachId) async {
    try {
      await dataSource.deleteCoach(coachId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> getAllCoaches() async {
    try {
      final coaches = await dataSource.getAllCoaches();
      return Right(coaches.map((c) => c.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> getCoachesBySpecialization(
    String specialization,
  ) async {
    try {
      final coaches =
          await dataSource.getCoachesBySpecialization(specialization);
      return Right(coaches.map((c) => c.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> getActiveCoaches() async {
    try {
      final coaches = await dataSource.getActiveCoaches();
      return Right(coaches.map((c) => c.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> getCoachesAvailableOn(
      String day) async {
    try {
      final coaches = await dataSource.getCoachesAvailableOn(day);
      return Right(coaches.map((c) => c.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> searchCoachesByName(
      String name) async {
    try {
      final coaches = await dataSource.searchCoachesByName(name);
      return Right(coaches.map((c) => c.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCoachRating(
    String coachId,
    double rating,
  ) async {
    try {
      await dataSource.updateCoachRating(coachId, rating);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSessionCount(
    String coachId,
    int count,
  ) async {
    try {
      await dataSource.updateSessionCount(coachId, count);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
