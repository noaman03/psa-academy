import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player_entity.dart';

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.level,
    required super.category,
    required super.ageGroup,
    super.parentName,
    super.parentPhone,
    super.emergencyContact,
    super.dateOfBirth,
    super.address,
    super.medicalInfo,
    super.height,
    super.weight,
    super.position,
    required super.joinDate,
    super.lastAttendance,
    super.attendanceCount,
    super.paymentBalance,
    super.isActive,
    super.stats,
  });

  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      level: entity.level,
      category: entity.category,
      ageGroup: entity.ageGroup,
      parentName: entity.parentName,
      parentPhone: entity.parentPhone,
      emergencyContact: entity.emergencyContact,
      dateOfBirth: entity.dateOfBirth,
      address: entity.address,
      medicalInfo: entity.medicalInfo,
      height: entity.height,
      weight: entity.weight,
      position: entity.position,
      joinDate: entity.joinDate,
      lastAttendance: entity.lastAttendance,
      attendanceCount: entity.attendanceCount,
      paymentBalance: entity.paymentBalance,
      isActive: entity.isActive,
      stats: entity.stats,
    );
  }

  factory PlayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlayerModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      level: data['level'] ?? '',
      category: data['category'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      parentName: data['parentName'],
      parentPhone: data['parentPhone'],
      emergencyContact: data['emergencyContact'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      address: data['address'],
      medicalInfo: data['medicalInfo'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      position: data['position'],
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAttendance: (data['lastAttendance'] as Timestamp?)?.toDate(),
      attendanceCount: data['attendanceCount'] ?? 0,
      paymentBalance: (data['paymentBalance'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      stats: data['stats'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'level': level,
      'category': category,
      'ageGroup': ageGroup,
      if (parentName != null) 'parentName': parentName,
      if (parentPhone != null) 'parentPhone': parentPhone,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (address != null) 'address': address,
      if (medicalInfo != null) 'medicalInfo': medicalInfo,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (position != null) 'position': position,
      'joinDate': Timestamp.fromDate(joinDate),
      if (lastAttendance != null)
        'lastAttendance': Timestamp.fromDate(lastAttendance!),
      'attendanceCount': attendanceCount,
      'paymentBalance': paymentBalance,
      'isActive': isActive,
      if (stats != null) 'stats': stats,
    };
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      id: id,
      userId: userId,
      name: name,
      level: level,
      category: category,
      ageGroup: ageGroup,
      parentName: parentName,
      parentPhone: parentPhone,
      emergencyContact: emergencyContact,
      dateOfBirth: dateOfBirth,
      address: address,
      medicalInfo: medicalInfo,
      height: height,
      weight: weight,
      position: position,
      joinDate: joinDate,
      lastAttendance: lastAttendance,
      attendanceCount: attendanceCount,
      paymentBalance: paymentBalance,
      isActive: isActive,
      stats: stats,
    );
  }
}
