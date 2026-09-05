import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'player', 'coach'
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        phoneNumber,
        profileImageUrl,
        createdAt,
        updatedAt,
        isActive,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isPlayer => role == 'player';
  bool get isCoach => role == 'coach';
}
