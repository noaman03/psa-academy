import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.playerId,
    required super.playerName,
    super.coachId,
    super.coachName,
    required super.date,
    super.status = 'present',
    super.type = 'fitness',
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

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return AttendanceModel(
      id: doc.id,
      playerId: data['playerId'] ?? '',
      playerName: data['playerName'] ?? data['name'] ?? 'Player',
      coachId: data['coachId'],
      coachName: data['coachName'],
      date: parseRequiredDateTime(data['date']),
      status: data['status'] ?? 'present',
      type: data['type'] ?? 'fitness',
      category: data['category'],
      level: data['level'],
      notes: data['notes'],
      workoutId: data['workoutId'] ?? data['workoutTemplateId'],
      workoutName: data['workoutName'] ?? data['workout'],
      workoutDetails: data['workoutDetails'] as Map<String, dynamic>?,
      checkInTime: parseSafeDateTime(data['checkInTime']),
      checkOutTime: parseSafeDateTime(data['checkOutTime']),
      isSeen: data['isSeen'] ?? false,
      createdAt: parseRequiredDateTime(data['createdAt'], parseSafeDateTime(data['date'])),
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
      'type': type,
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
}
