import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String level; // 'Beginner', 'Intermediate', 'Advanced', 'Professional'
  final String category; // 'Junior', 'Senior', 'Elite'
  final String ageGroup; // 'Under 8', 'Under 10', 'Under 12', etc.
  final double balance; // Financial balance in EGP
  final int sessionsPaid; // Number of prepaid sessions
  final int sessionsAttended; // Number of attended sessions
  final bool isAllowedPlayer; // Can attend even if balance is 0
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
  final bool isActive;
  final List<dynamic>? history;

  const PlayerEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.email = '',
    this.phone,
    required this.level,
    required this.category,
    required this.ageGroup,
    this.balance = 0.0,
    this.sessionsPaid = 0,
    this.sessionsAttended = 0,
    this.isAllowedPlayer = true,
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
    this.isActive = true,
    this.history,
  });

  /// Remaining sessions = prepaid - attended
  int get remainingSessions => sessionsPaid - sessionsAttended;

  bool get canAttendSession => remainingSessions > 0 || isAllowedPlayer;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        level,
        category,
        ageGroup,
        balance,
        sessionsPaid,
        sessionsAttended,
        isAllowedPlayer,
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
        isActive,
        history,
      ];
}
