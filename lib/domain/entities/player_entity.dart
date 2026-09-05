import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String level; // 'Beginner', 'Intermediate', 'Advanced', 'Professional'
  final String category; // 'U10', 'U12', 'U14', 'U16', 'U18', 'Senior'
  final String ageGroup;
  final String? parentName;
  final String? parentPhone;
  final String? emergencyContact;
  final DateTime? dateOfBirth;
  final String? address;
  final String? medicalInfo;
  final double? height;
  final double? weight;
  final String? position;
  final DateTime joinDate;
  final DateTime? lastAttendance;
  final int attendanceCount;
  final double paymentBalance;
  final bool isActive;
  final Map<String, dynamic>? stats;

  const PlayerEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.level,
    required this.category,
    required this.ageGroup,
    this.parentName,
    this.parentPhone,
    this.emergencyContact,
    this.dateOfBirth,
    this.address,
    this.medicalInfo,
    this.height,
    this.weight,
    this.position,
    required this.joinDate,
    this.lastAttendance,
    this.attendanceCount = 0,
    this.paymentBalance = 0.0,
    this.isActive = true,
    this.stats,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        level,
        category,
        ageGroup,
        parentName,
        parentPhone,
        emergencyContact,
        dateOfBirth,
        address,
        medicalInfo,
        height,
        weight,
        position,
        joinDate,
        lastAttendance,
        attendanceCount,
        paymentBalance,
        isActive,
        stats,
      ];

  PlayerEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? level,
    String? category,
    String? ageGroup,
    String? parentName,
    String? parentPhone,
    String? emergencyContact,
    DateTime? dateOfBirth,
    String? address,
    String? medicalInfo,
    double? height,
    double? weight,
    String? position,
    DateTime? joinDate,
    DateTime? lastAttendance,
    int? attendanceCount,
    double? paymentBalance,
    bool? isActive,
    Map<String, dynamic>? stats,
  }) {
    return PlayerEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      level: level ?? this.level,
      category: category ?? this.category,
      ageGroup: ageGroup ?? this.ageGroup,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      position: position ?? this.position,
      joinDate: joinDate ?? this.joinDate,
      lastAttendance: lastAttendance ?? this.lastAttendance,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      paymentBalance: paymentBalance ?? this.paymentBalance,
      isActive: isActive ?? this.isActive,
      stats: stats ?? this.stats,
    );
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  bool get hasOutstandingBalance => paymentBalance > 0;
}
