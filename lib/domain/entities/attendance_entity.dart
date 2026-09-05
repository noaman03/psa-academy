import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final String? coachId;
  final String? coachName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final String type; // 'fitness', 'recovery'
  final String? category;
  final String? level;
  final String? notes;
  final String? workoutId;
  final String? workoutName;
  final Map<String, dynamic>? workoutDetails;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool isSeen;
  final DateTime createdAt;

  const AttendanceEntity({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.coachId,
    this.coachName,
    required this.date,
    this.status = 'present',
    this.type = 'fitness',
    this.category,
    this.level,
    this.notes,
    this.workoutId,
    this.workoutName,
    this.workoutDetails,
    this.checkInTime,
    this.checkOutTime,
    this.isSeen = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        playerId,
        playerName,
        coachId,
        coachName,
        date,
        status,
        type,
        category,
        level,
        notes,
        workoutId,
        workoutName,
        workoutDetails,
        checkInTime,
        checkOutTime,
        isSeen,
        createdAt,
      ];
}
