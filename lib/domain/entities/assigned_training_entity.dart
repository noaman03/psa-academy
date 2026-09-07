import 'package:equatable/equatable.dart';
import 'training_template_entity.dart';

class AssignedTrainingEntity extends Equatable {
  final String id;
  final String attendanceId;
  final String playerId;
  final String playerName;
  final String? coachId;
  final String? coachName;
  final String? templateId;
  final String trainingName;
  final String category;
  final String? targetMuscle;
  final String description;
  final List<ExerciseEntity> exercises;
  final String? notes;
  final DateTime assignedDate;
  final DateTime createdAt;

  const AssignedTrainingEntity({
    required this.id,
    required this.attendanceId,
    required this.playerId,
    required this.playerName,
    this.coachId,
    this.coachName,
    this.templateId,
    required this.trainingName,
    this.category = 'Fitness',
    this.targetMuscle,
    this.description = '',
    this.exercises = const [],
    this.notes,
    required this.assignedDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        attendanceId,
        playerId,
        playerName,
        coachId,
        coachName,
        templateId,
        trainingName,
        category,
        targetMuscle,
        description,
        exercises,
        notes,
        assignedDate,
        createdAt,
      ];
}
