import 'package:equatable/equatable.dart';

class CoachEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String specialization;
  final List<String> certifications;
  final int yearsOfExperience;
  final String? bio;
  final List<String> availability;
  final double hourlyRate;
  final double totalWorkedHours;
  final bool isAllowedCoach;
  final DateTime joinDate;
  final bool isActive;
  final double rating;
  final int totalSessions;
  final List<String>? assignedCategories;

  const CoachEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.email = '',
    this.phoneNumber,
    required this.specialization,
    this.certifications = const [],
    this.yearsOfExperience = 0,
    this.bio,
    this.availability = const [],
    this.hourlyRate = 50.0,
    this.totalWorkedHours = 0.0,
    this.isAllowedCoach = true,
    required this.joinDate,
    this.isActive = true,
    this.rating = 0.0,
    this.totalSessions = 0,
    this.assignedCategories,
  });

  String? get phone => phoneNumber;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phoneNumber,
        specialization,
        certifications,
        yearsOfExperience,
        bio,
        availability,
        hourlyRate,
        totalWorkedHours,
        isAllowedCoach,
        joinDate,
        isActive,
        rating,
        totalSessions,
        assignedCategories,
      ];
}
