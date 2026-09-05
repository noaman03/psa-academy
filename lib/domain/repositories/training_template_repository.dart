import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/training_template_entity.dart';

abstract class TrainingTemplateRepository {
  Future<Either<Failure, List<TrainingTemplateEntity>>> getTemplates();
  Future<Either<Failure, TrainingTemplateEntity>> createTemplate(TrainingTemplateEntity template);
  Future<Either<Failure, void>> updateTemplate(TrainingTemplateEntity template);
  Future<Either<Failure, void>> deleteTemplate(String templateId);
  Stream<List<TrainingTemplateEntity>> watchTemplates();
}
