import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/assigned_training_entity.dart';
import '../entities/training_template_entity.dart';

abstract class TrainingTemplateRepository {
  Future<Either<Failure, List<TrainingTemplateEntity>>> getTemplates();
  Future<Either<Failure, TrainingTemplateEntity>> createTemplate(TrainingTemplateEntity template);
  Future<Either<Failure, void>> updateTemplate(TrainingTemplateEntity template);
  Future<Either<Failure, void>> deleteTemplate(String templateId);
  Stream<List<TrainingTemplateEntity>> watchTemplates();

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
  });

  Future<Either<Failure, AssignedTrainingEntity?>> getAssignedTraining(String assignmentId);
}

