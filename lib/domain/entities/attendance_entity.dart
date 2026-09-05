import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final String playerId;
  final String playerName;
  final String? coachId;
  final String? coachName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late', 'excused'
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
    required this.status,
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

  AttendanceEntity copyWith({
    String? id,
    String? playerId,
    String? playerName,
    String? coachId,
    String? coachName,
    DateTime? date,
    String? status,
    String? category,
    String? level,
    String? notes,
    String? workoutId,
    String? workoutName,
    Map<String, dynamic>? workoutDetails,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isSeen,
    DateTime? createdAt,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      date: date ?? this.date,
      status: status ?? this.status,
      category: category ?? this.category,
      level: level ?? this.level,
      notes: notes ?? this.notes,
      workoutId: workoutId ?? this.workoutId,
      workoutName: workoutName ?? this.workoutName,
      workoutDetails: workoutDetails ?? this.workoutDetails,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isSeen: isSeen ?? this.isSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isExcused => status == 'excused';

  Duration? get sessionDuration {
    if (checkInTime == null || checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime!);
  }
}
