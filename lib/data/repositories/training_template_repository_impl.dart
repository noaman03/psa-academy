import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/training_template_entity.dart';
import '../../domain/repositories/training_template_repository.dart';
import '../models/training_template_model.dart';

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
}
