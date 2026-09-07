import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/training_template_entity.dart';
import '../../domain/entities/assigned_training_entity.dart';
import '../../domain/repositories/training_template_repository.dart';
import '../models/training_template_model.dart';
import '../models/assigned_training_model.dart';

class TrainingTemplateRepositoryImpl implements TrainingTemplateRepository {
  final FirebaseFirestore _firestore;

  TrainingTemplateRepositoryImpl([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<TrainingTemplateEntity>>> getTemplates() async {
    try {
      final snapshot =
          await _firestore.collection('trainingTemplates').get();
      final list = snapshot.docs
          .map((doc) => TrainingTemplateModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.trainingName.compareTo(b.trainingName));
      return Right(list);
    } catch (e) {
      return Left(FirestoreFailure('Failed to load training templates: $e'));
    }
  }

  @override
  Future<Either<Failure, TrainingTemplateEntity>> createTemplate(
    TrainingTemplateEntity template,
  ) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection('trainingTemplates').add({
        'trainingName': template.trainingName.trim(),
        'description': template.description.trim(),
        'exercises': template.exercises.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(now),
      });

      return Right(
        TrainingTemplateModel(
          id: docRef.id,
          trainingName: template.trainingName,
          description: template.description,
          exercises: template.exercises,
          createdAt: now,
        ),
      );
    } catch (e) {
      return Left(FirestoreFailure('Failed to create training template: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTemplate(
    TrainingTemplateEntity template,
  ) async {
    try {
      await _firestore
          .collection('trainingTemplates')
          .doc(template.id)
          .update({
        'trainingName': template.trainingName.trim(),
        'description': template.description.trim(),
        'exercises': template.exercises.map((e) => e.toMap()).toList(),
      });
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to update training template: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String templateId) async {
    try {
      await _firestore
          .collection('trainingTemplates')
          .doc(templateId)
          .delete();
      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to delete training template: $e'));
    }
  }

  @override
  Stream<List<TrainingTemplateEntity>> watchTemplates() {
    return _firestore
        .collection('trainingTemplates')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TrainingTemplateModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => a.trainingName.compareTo(b.trainingName));
      return list;
    });
  }

  @override
  Future<Either<Failure, AssignedTrainingEntity>> assignTrainingSnapshot({
    required String attendanceId,
    required String playerId,
    required String playerName,
    String? coachId,
    String? coachName,
    String? templateId,
    required String trainingName,
    required String category,
    String? targetMuscle,
    required String description,
    required List<ExerciseEntity> exercises,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final exerciseMaps = exercises.map((e) => e.toMap()).toList();

      final assignedDocRef = _firestore.collection('assignedTrainings').doc();
      final assignmentId = assignedDocRef.id;

      final snapshotData = {
        'id': assignmentId,
        'attendanceId': attendanceId,
        'playerId': playerId,
        'playerName': playerName,
        if (coachId != null) 'coachId': coachId,
        if (coachName != null) 'coachName': coachName,
        if (templateId != null) 'templateId': templateId,
        'trainingName': trainingName.trim(),
        'category': category.trim(),
        if (targetMuscle != null) 'targetMuscle': targetMuscle.trim(),
        'description': description.trim(),
        'exercises': exerciseMaps,
        if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
        'assignedDate': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
      };

      await assignedDocRef.set(snapshotData);

      // Link snapshot directly to the attendance session if specified
      if (attendanceId.isNotEmpty) {
        await _firestore.collection('attendance').doc(attendanceId).update({
          'workoutId': assignmentId,
          'workoutName': trainingName.trim(),
          'workoutDetails': {
            'assignmentId': assignmentId,
            'trainingName': trainingName.trim(),
            'category': category.trim(),
            if (targetMuscle != null) 'targetMuscle': targetMuscle.trim(),
            'description': description.trim(),
            'exercises': exerciseMaps,
            if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
          },
        });
      }

      final entity = AssignedTrainingModel(
        id: assignmentId,
        attendanceId: attendanceId,
        playerId: playerId,
        playerName: playerName,
        coachId: coachId,
        coachName: coachName,
        templateId: templateId,
        trainingName: trainingName,
        category: category,
        targetMuscle: targetMuscle,
        description: description,
        exercises: exercises,
        notes: notes,
        assignedDate: now,
        createdAt: now,
      );

      return Right(entity);
    } catch (e) {
      return Left(FirestoreFailure('Failed to assign training: $e'));
    }
  }

  @override
  Future<Either<Failure, AssignedTrainingEntity?>> getAssignedTraining(
    String assignmentId,
  ) async {
    try {
      final doc = await _firestore.collection('assignedTrainings').doc(assignmentId).get();
      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }
      return Right(AssignedTrainingModel.fromFirestore(doc));
    } catch (e) {
      return Left(FirestoreFailure('Failed to load assigned training: $e'));
    }
  }
}

