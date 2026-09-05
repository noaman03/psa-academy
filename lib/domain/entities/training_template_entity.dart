import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String instructions;
  final String sets;
  final String reps;

  const ExerciseEntity({
    this.id = '',
    String? name,
    String? exerciseName,
    this.instructions = '',
    this.sets = '3',
    this.reps = '10',
  }) : name = exerciseName ?? name ?? 'Exercise';

  String get exerciseName => name;

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? exerciseName,
    String? instructions,
    String? sets,
    String? reps,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: exerciseName ?? name ?? this.name,
      instructions: instructions ?? this.instructions,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
    );
  }

  @override
  List<Object?> get props => [id, name, instructions, sets, reps];

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'exerciseName': name,
        'instructions': instructions,
        'sets': sets,
        'reps': reps,
      };

  factory ExerciseEntity.fromMap(Map<String, dynamic> map) {
    final String exName = map['exerciseName'] ??
        map['name'] ??
        map['trainingName'] ??
        'Exercise';
    return ExerciseEntity(
      id: map['id'] ?? map['exerciseId'] ?? '',
      name: exName,
      instructions: map['instructions'] ?? '',
      sets: map['sets']?.toString() ?? '3',
      reps: map['reps']?.toString() ?? '10',
    );
  }
}

// Alias for presentation builder
typedef ExerciseItemEntity = ExerciseEntity;

class TrainingTemplateEntity extends Equatable {
  final String id;
  final String trainingName;
  final String category;
  final String? targetMuscle;
  final String description;
  final List<ExerciseEntity> exercises;
  final DateTime createdAt;

  const TrainingTemplateEntity({
    required this.id,
    required this.trainingName,
    this.category = 'General',
    this.targetMuscle,
    this.description = '',
    this.exercises = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        trainingName,
        category,
        targetMuscle,
        description,
        exercises,
        createdAt,
      ];
}
