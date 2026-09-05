import 'package:equatable/equatable.dart';

enum UserRole { admin, coach, player, unknown }

class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;
  bool get isPlayer => role == UserRole.player;

  static UserRole roleFromString(String? role) {
    if (role == null) return UserRole.unknown;
    switch (role.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'coach':
        return UserRole.coach;
      case 'player':
        return UserRole.player;
      default:
        return UserRole.unknown;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.coach:
        return 'coach';
      case UserRole.player:
        return 'player';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        phoneNumber,
        profileImageUrl,
        isActive,
        createdAt,
      ];
}
