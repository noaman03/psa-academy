import 'package:equatable/equatable.dart';

class CoachEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String specialization;
  final List<String> certifications;
  final int yearsOfExperience;
  final String? bio;
  final List<String> availability; // Days: 'Monday', 'Tuesday', etc.
  final String? phoneNumber;
  final String? email;
  final DateTime joinDate;
  final bool isActive;
  final double rating;
  final int totalSessions;
  final List<String>? assignedCategories;

  const CoachEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialization,
    this.certifications = const [],
    this.yearsOfExperience = 0,
    this.bio,
    this.availability = const [],
    this.phoneNumber,
    this.email,
    required this.joinDate,
    this.isActive = true,
    this.rating = 0.0,
    this.totalSessions = 0,
    this.assignedCategories,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        specialization,
        certifications,
        yearsOfExperience,
        bio,
        availability,
        phoneNumber,
        email,
        joinDate,
        isActive,
        rating,
        totalSessions,
        assignedCategories,
      ];

  CoachEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? specialization,
    List<String>? certifications,
    int? yearsOfExperience,
    String? bio,
    List<String>? availability,
    String? phoneNumber,
    String? email,
    DateTime? joinDate,
    bool? isActive,
    double? rating,
    int? totalSessions,
    List<String>? assignedCategories,
  }) {
    return CoachEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      certifications: certifications ?? this.certifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      availability: availability ?? this.availability,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      assignedCategories: assignedCategories ?? this.assignedCategories,
    );
  }

  bool isAvailableOn(String day) => availability.contains(day);
}
