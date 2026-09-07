import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/assigned_training_entity.dart';
import '../../domain/entities/training_template_entity.dart';

class AssignedTrainingModel extends AssignedTrainingEntity {
  const AssignedTrainingModel({
    required super.id,
    required super.attendanceId,
    required super.playerId,
    required super.playerName,
    super.coachId,
    super.coachName,
    super.templateId,
    required super.trainingName,
    super.category = 'Fitness',
    super.targetMuscle,
    super.description = '',
    super.exercises = const [],
    super.notes,
    required super.assignedDate,
    required super.createdAt,
  });

  factory AssignedTrainingModel.fromJson(Map<String, dynamic> data, [String? docId]) {
    final String trainingName =
        data['trainingName'] ?? data['workoutName'] ?? 'Assigned Routine';
    final String category = data['category'] ?? 'Fitness';
    final String? targetMuscle = data['targetMuscle'];
    final String description = data['description'] ?? '';
    final String? notes = data['notes'];

    List<ExerciseItemEntity> exercises = [];
    if (data['exercises'] is List) {
      exercises = (data['exercises'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ExerciseItemEntity.fromMap(e))
          .toList();
    }

    return AssignedTrainingModel(
      id: docId ?? data['id'] ?? '',
      attendanceId: data['attendanceId'] ?? '',
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? 'Player',
      coachId: data['coachId'],
      coachName: data['coachName'],
      templateId: data['templateId'],
      trainingName: trainingName,
      category: category,
      targetMuscle: targetMuscle,
      description: description,
      exercises: exercises,
      notes: notes,
      assignedDate: parseSafeDateTime(data['assignedDate']) ??
          parseSafeDateTime(data['date']) ??
          DateTime.now(),
      createdAt: parseSafeDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  factory AssignedTrainingModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AssignedTrainingModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendanceId': attendanceId,
      'playerId': playerId,
      'playerName': playerName,
      if (coachId != null) 'coachId': coachId,
      if (coachName != null) 'coachName': coachName,
      if (templateId != null) 'templateId': templateId,
      'trainingName': trainingName,
      'category': category,
      if (targetMuscle != null) 'targetMuscle': targetMuscle,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'assignedDate': Timestamp.fromDate(assignedDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
