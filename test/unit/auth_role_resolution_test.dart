import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/domain/entities/app_user.dart';

void main() {
  group('Auth & Role Resolution Tests', () {
    test('roleFromString correctly parses valid roles', () {
      expect(AppUser.roleFromString('admin'), equals(UserRole.admin));
      expect(AppUser.roleFromString('ADMIN'), equals(UserRole.admin));
      expect(AppUser.roleFromString('coach'), equals(UserRole.coach));
      expect(AppUser.roleFromString('COACH'), equals(UserRole.coach));
      expect(AppUser.roleFromString('player'), equals(UserRole.player));
      expect(AppUser.roleFromString('PLAYER'), equals(UserRole.player));
    });

    test('roleFromString defaults to unknown on invalid or null roles', () {
      expect(AppUser.roleFromString(null), equals(UserRole.unknown));
      expect(AppUser.roleFromString(''), equals(UserRole.unknown));
      expect(AppUser.roleFromString('superadmin'), equals(UserRole.unknown));
      expect(AppUser.roleFromString('manager'), equals(UserRole.unknown));
      expect(AppUser.roleFromString('guest'), equals(UserRole.unknown));
    });

    test('AppUser properties and equality', () {
      final now = DateTime(2026, 1, 1);
      final user1 = AppUser(
        id: 'u-123',
        email: 'coach@psa.com',
        name: 'Coach Ahmed',
        role: UserRole.coach,
        createdAt: now,
      );
      final user2 = AppUser(
        id: 'u-123',
        email: 'coach@psa.com',
        name: 'Coach Ahmed',
        role: UserRole.coach,
        createdAt: now,
      );

      expect(user1, equals(user2));
      expect(user1.role, equals(UserRole.coach));
    });
  });
}
