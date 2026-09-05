import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/coach_entity.dart';

class CoachModel extends CoachEntity {
  const CoachModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.specialization,
    super.certifications = const [],
    super.yearsOfExperience = 0,
    super.bio,
    super.availability = const [],
    super.phoneNumber,
    super.email,
    required super.joinDate,
    super.isActive = true,
    super.rating = 0.0,
    super.totalSessions = 0,
    super.assignedCategories,
  });

  factory CoachModel.fromEntity(CoachEntity entity) {
    return CoachModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      specialization: entity.specialization,
      certifications: entity.certifications,
      yearsOfExperience: entity.yearsOfExperience,
      bio: entity.bio,
      availability: entity.availability,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      joinDate: entity.joinDate,
      isActive: entity.isActive,
      rating: entity.rating,
      totalSessions: entity.totalSessions,
      assignedCategories: entity.assignedCategories,
    );
  }

  factory CoachModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoachModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      certifications: (data['certifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      bio: data['bio'],
      availability: (data['availability'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
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
      'specialization': specialization,
      'certifications': certifications,
      'yearsOfExperience': yearsOfExperience,
      if (bio != null) 'bio': bio,
      'availability': availability,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'joinDate': Timestamp.fromDate(joinDate),
      'isActive': isActive,
      'rating': rating,
      'totalSessions': totalSessions,
      if (assignedCategories != null) 'assignedCategories': assignedCategories,
    };
  }

  CoachEntity toEntity() {
    return CoachEntity(
      id: id,
      userId: userId,
      name: name,
      specialization: specialization,
      certifications: certifications,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      availability: availability,
      phoneNumber: phoneNumber,
      email: email,
      joinDate: joinDate,
      isActive: isActive,
      rating: rating,
      totalSessions: totalSessions,
      assignedCategories: assignedCategories,
    );
  }
}
