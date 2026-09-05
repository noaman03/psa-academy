import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/training_template_entity.dart';

class TrainingTemplateModel extends TrainingTemplateEntity {
  const TrainingTemplateModel({
    required super.id,
    required super.trainingName,
    super.category = 'General',
    super.targetMuscle,
    super.description = '',
    super.exercises = const [],
    required super.createdAt,
  });

  factory TrainingTemplateModel.fromJson(Map<String, dynamic> data, [String? docId]) {
    // Safe handling of legacy keys with trailing spaces
    final String trainingName =
        data['trainingName'] ?? data['trainingName '] ?? 'Training Template';
    final String category =
        data['category'] ?? data['category '] ?? 'General';
    final String? targetMuscle =
        data['targetMuscle'] ?? data['targetMuscle '];
    final String description =
        data['description'] ?? data['description '] ?? '';

    List<ExerciseItemEntity> exercises = [];
    if (data['exercises'] is List) {
      exercises = (data['exercises'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ExerciseItemEntity.fromMap(e))
          .toList();
    }

    return TrainingTemplateModel(
      id: docId ?? data['id'] ?? '',
      trainingName: trainingName,
      category: category,
      targetMuscle: targetMuscle,
      description: description,
      exercises: exercises,
      createdAt: DateParser.parse(data['createdAt']),
    );
  }

  factory TrainingTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return TrainingTemplateModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingName': trainingName,
      'category': category,
      if (targetMuscle != null) 'targetMuscle': targetMuscle,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() => toJson();
}
