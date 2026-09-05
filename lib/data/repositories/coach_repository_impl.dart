import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/coach_entity.dart';
import '../../domain/entities/coach_work_session_entity.dart';
import '../../domain/repositories/coach_repository.dart';
import '../models/coach_model.dart';
import '../models/coach_work_session_model.dart';

class CoachRepositoryImpl implements CoachRepository {
  final FirebaseFirestore _firestore;

  CoachRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, CoachEntity>> getCoachById(String coachId) async {
    try {
      final doc = await _firestore.collection('coaches').doc(coachId).get();
      if (!doc.exists) {
        return const Left(FirestoreFailure('Coach document not found.'));
      }
      return Right(CoachModel.fromFirestore(doc));
    } catch (e) {
      return Left(FirestoreFailure('Failed to get coach: $e'));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> createCoach(CoachEntity coach) async {
    try {
      final model = CoachModel(
        id: coach.id,
        userId: coach.userId,
        name: coach.name,
        email: coach.email,
        phoneNumber: coach.phoneNumber,
        specialization: coach.specialization,
        certifications: coach.certifications,
        yearsOfExperience: coach.yearsOfExperience,
        bio: coach.bio,
        availability: coach.availability,
        hourlyRate: coach.hourlyRate,
        totalWorkedHours: coach.totalWorkedHours,
        isAllowedCoach: coach.isAllowedCoach,
        joinDate: coach.joinDate,
        isActive: coach.isActive,
      );

      await _firestore
          .collection('coaches')
          .doc(coach.id)
          .set(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(FirestoreFailure('Failed to create coach: $e'));
    }
  }

  @override
  Future<Either<Failure, CoachEntity>> updateCoach(CoachEntity coach) async {
    try {
      final model = CoachModel(
        id: coach.id,
        userId: coach.userId,
        name: coach.name,
        email: coach.email,
        phoneNumber: coach.phoneNumber,
        specialization: coach.specialization,
        certifications: coach.certifications,
        yearsOfExperience: coach.yearsOfExperience,
        bio: coach.bio,
        availability: coach.availability,
        hourlyRate: coach.hourlyRate,
        totalWorkedHours: coach.totalWorkedHours,
        isAllowedCoach: coach.isAllowedCoach,
        joinDate: coach.joinDate,
        isActive: coach.isActive,
      );

      await _firestore
          .collection('coaches')
          .doc(coach.id)
          .update(model.toFirestore());

      return Right(model);
    } catch (e) {
      return Left(FirestoreFailure('Failed to update coach: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoach(String coachId) async {
    try {
      await _firestore.collection('coaches').doc(coachId).delete();
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to delete coach: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CoachEntity>>> getAllCoaches() async {
    try {
      final snapshot = await _firestore.collection('coaches').get();
      final coaches = snapshot.docs
          .map((doc) => CoachModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return Right(coaches);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch coaches: $e'));
    }
  }

  @override
  Future<Either<Failure, CoachWorkSessionEntity?>> getActiveWorkSession(
    String coachId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('coachWorkSessions')
          .where('coachId', isEqualTo: coachId)
          .where('checkOut', isNull: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }
      return Right(CoachWorkSessionModel.fromFirestore(snapshot.docs.first));
    } catch (e) {
      return Left(FirestoreFailure('Failed to check active session: $e'));
    }
  }

  @override
  Future<Either<Failure, CoachWorkSessionEntity>> checkInCoach(
    String coachId,
    String coachName,
  ) async {
    try {
      // Check if already checked in
      final active = await getActiveWorkSession(coachId);
      final existing = active.fold((l) => null, (r) => r);
      if (existing != null) {
        return Right(existing);
      }

      final now = DateTime.now();
      final docRef = await _firestore.collection('coachWorkSessions').add({
        'coachId': coachId,
        'coachName': coachName,
        'checkIn': Timestamp.fromDate(now),
        'checkOut': null,
        'hoursWorked': 0.0,
        'calculatedSalary': 0.0,
        'date': Timestamp.fromDate(now),
      });

      return Right(
        CoachWorkSessionModel(
          id: docRef.id,
          coachId: coachId,
          coachName: coachName,
          checkIn: now,
          date: now,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Check-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, CoachWorkSessionEntity>> checkOutCoach(
    String coachId,
    double hourlyRate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('coachWorkSessions')
          .where('coachId', isEqualTo: coachId)
          .where('checkOut', isNull: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Left(FirestoreFailure('No active session to check out.'));
      }

      final doc = snapshot.docs.first;
      final session = CoachWorkSessionModel.fromFirestore(doc);
      final now = DateTime.now();

      final duration = now.difference(session.checkIn);
      final double hoursWorked = duration.inMinutes / 60.0;
      final double calculatedSalary = hoursWorked * hourlyRate;

      // Update session document
      await _firestore.collection('coachWorkSessions').doc(doc.id).update({
        'checkOut': Timestamp.fromDate(now),
        'hoursWorked': hoursWorked,
        'calculatedSalary': calculatedSalary,
      });

      // Update coach cumulative worked hours
      await _firestore.collection('coaches').doc(coachId).update({
        'totalWorkedHours': FieldValue.increment(hoursWorked),
      });

      return Right(
        CoachWorkSessionModel(
          id: session.id,
          coachId: coachId,
          coachName: session.coachName,
          checkIn: session.checkIn,
          checkOut: now,
          hoursWorked: hoursWorked,
          calculatedSalary: calculatedSalary,
          date: session.date,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Check-out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CoachWorkSessionEntity>>> getCoachWorkSessions(
    String coachId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('coachWorkSessions')
          .where('coachId', isEqualTo: coachId)
          .limit(30)
          .get();

      final list = snapshot.docs
          .map((doc) => CoachWorkSessionModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.checkIn.compareTo(a.checkIn));

      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to load coach history: $e'));
    }
  }
}
