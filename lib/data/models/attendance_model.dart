import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.playerId,
    required super.playerName,
    super.coachId,
    super.coachName,
    required super.date,
    required super.status,
    super.category,
    super.level,
    super.notes,
    super.workoutId,
    super.workoutName,
    super.workoutDetails,
    super.checkInTime,
    super.checkOutTime,
    super.isSeen = false,
    required super.createdAt,
  });

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      playerId: entity.playerId,
      playerName: entity.playerName,
      coachId: entity.coachId,
      coachName: entity.coachName,
      date: entity.date,
      status: entity.status,
      category: entity.category,
      level: entity.level,
      notes: entity.notes,
      workoutId: entity.workoutId,
      workoutName: entity.workoutName,
      workoutDetails: entity.workoutDetails,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      isSeen: entity.isSeen,
      createdAt: entity.createdAt,
    );
  }

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? '',
      coachId: data['coachId'],
      coachName: data['coachName'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'present',
      category: data['category'],
      level: data['level'],
      notes: data['notes'],
      workoutId: data['workoutId'],
      workoutName: data['workoutName'],
      workoutDetails: data['workoutDetails'] as Map<String, dynamic>?,
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      isSeen: data['isSeen'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      if (coachId != null) 'coachId': coachId,
      if (coachName != null) 'coachName': coachName,
      'date': Timestamp.fromDate(date),
      'status': status,
      if (category != null) 'category': category,
      if (level != null) 'level': level,
      if (notes != null) 'notes': notes,
      if (workoutId != null) 'workoutId': workoutId,
      if (workoutName != null) 'workoutName': workoutName,
      if (workoutDetails != null) 'workoutDetails': workoutDetails,
      if (checkInTime != null) 'checkInTime': Timestamp.fromDate(checkInTime!),
      if (checkOutTime != null)
        'checkOutTime': Timestamp.fromDate(checkOutTime!),
      'isSeen': isSeen,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AttendanceEntity toEntity() {
    return AttendanceEntity(
      id: id,
      playerId: playerId,
      playerName: playerName,
      coachId: coachId,
      coachName: coachName,
      date: date,
      status: status,
      category: category,
      level: level,
      notes: notes,
      workoutId: workoutId,
      workoutName: workoutName,
      workoutDetails: workoutDetails,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      isSeen: isSeen,
      createdAt: createdAt,
    );
  }
}
