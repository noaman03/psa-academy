import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_parser.dart';
import '../../domain/entities/coach_entity.dart';

class CoachModel extends CoachEntity {
  const CoachModel({
    required super.id,
    required super.userId,
    required super.name,
    super.email = '',
    super.phoneNumber,
    required super.specialization,
    super.certifications = const [],
    super.yearsOfExperience = 0,
    super.bio,
    super.availability = const [],
    super.hourlyRate = 50.0,
    super.totalWorkedHours = 0.0,
    super.isAllowedCoach = true,
    required super.joinDate,
    super.isActive = true,
    super.rating = 0.0,
    super.totalSessions = 0,
    super.assignedCategories,
  });

  factory CoachModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    return CoachModel(
      id: doc.id,
      userId: data['userId'] ?? data['uid'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone'],
      specialization: data['specialization'] ?? 'Technical Coach',
      certifications: (data['certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      yearsOfExperience: data['yearsOfExperience'] ??
          data['experienceYears'] ??
          0,
      bio: data['bio'],
      availability: (data['availability'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 50.0,
      totalWorkedHours: (data['totalWorkedHours'] as num?)?.toDouble() ??
          (data['working hours'] as num?)?.toDouble() ??
          0.0,
      isAllowedCoach: data['isAllowedCoach'] ?? data['isAllowed'] ?? true,
      joinDate: parseRequiredDateTime(data['joinDate']),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalSessions: data['totalSessions'] ?? 0,
      assignedCategories: (data['assignedCategories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'specialization': specialization,
      'certifications': certifications,
      'yearsOfExperience': yearsOfExperience,
      if (bio != null) 'bio': bio,
      'availability': availability,
      'hourlyRate': hourlyRate,
      'totalWorkedHours': totalWorkedHours,
      'isAllowedCoach': isAllowedCoach,
      'joinDate': Timestamp.fromDate(joinDate),
      'isActive': isActive,
      'rating': rating,
      'totalSessions': totalSessions,
      if (assignedCategories != null) 'assignedCategories': assignedCategories,
    };
  }

  CoachModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? specialization,
    List<String>? certifications,
    int? yearsOfExperience,
    String? bio,
    List<String>? availability,
    double? hourlyRate,
    double? totalWorkedHours,
    bool? isAllowedCoach,
    DateTime? joinDate,
    bool? isActive,
    double? rating,
    int? totalSessions,
    List<String>? assignedCategories,
  }) {
    return CoachModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      specialization: specialization ?? this.specialization,
      certifications: certifications ?? this.certifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      availability: availability ?? this.availability,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalWorkedHours: totalWorkedHours ?? this.totalWorkedHours,
      isAllowedCoach: isAllowedCoach ?? this.isAllowedCoach,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      assignedCategories: assignedCategories ?? this.assignedCategories,
    );
  }
}
