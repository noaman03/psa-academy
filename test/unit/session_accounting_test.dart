import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/data/models/player_model.dart';
import 'package:psa_academy/domain/entities/player_entity.dart';

void main() {
  group('Session Accounting & Overdraft Prevention Tests', () {
    test('Legacy schema (version < 2) converts remaining sessions to cumulative lifetime paid', () {
      // In legacy, sessionPaid was decremented on attendance: 5 remaining sessions, 12 already attended
      final legacyDoc = {
        'name': 'Legacy Student',
        'sessionPaid': 5,
        'sessionsAttended': 12,
        'level': 'Intermediate',
        'category': 'Junior',
        'ageGroup': 'U12',
        // schemaVersion is absent (defaults to 1)
      };

      final player = PlayerModel.fromJson(legacyDoc, 'p-legacy-1');

      // Cumulative paid should be converted: 5 + 12 = 17
      expect(player.sessionsPaid, equals(17));
      expect(player.sessionsAttended, equals(12));
      // Remaining sessions must be exactly 5
      expect(player.remainingSessions, equals(5));
      expect(player.canAttendSession, isTrue);
    });

    test('Modern schema (version 2) preserves canonical cumulative sessionsPaid', () {
      final modernDoc = {
        'schemaVersion': 2,
        'name': 'Modern Student',
        'sessionsPaid': 20,
        'sessionsAttended': 15,
        'level': 'Advanced',
        'category': 'Senior',
        'ageGroup': 'U18',
      };

      final player = PlayerModel.fromJson(modernDoc, 'p-modern-1');

      expect(player.sessionsPaid, equals(20));
      expect(player.sessionsAttended, equals(15));
      expect(player.remainingSessions, equals(5));
      expect(player.canAttendSession, isTrue);
    });

    test('Player with zero remaining sessions is rejected if not allowed player', () {
      final player = PlayerEntity(
        id: 'p-exhausted',
        userId: 'u-exhausted',
        name: 'Exhausted Player',
        level: 'Intermediate',
        category: 'Junior',
        ageGroup: 'U14',
        sessionsPaid: 10,
        sessionsAttended: 10,
        isAllowedPlayer: false, // Disallowed overdraft
        joinDate: DateTime(2025, 1, 1),
      );

      expect(player.remainingSessions, equals(0));
      expect(player.canAttendSession, isFalse);
    });

    test('Player with zero remaining sessions is permitted if isAllowedPlayer is true', () {
      final player = PlayerEntity(
        id: 'p-vip',
        userId: 'u-vip',
        name: 'VIP Player',
        level: 'Advanced',
        category: 'Elite',
        ageGroup: 'U16',
        sessionsPaid: 10,
        sessionsAttended: 10,
        isAllowedPlayer: true, // Overdraft permitted
        joinDate: DateTime(2025, 1, 1),
      );

      expect(player.remainingSessions, equals(0));
      expect(player.canAttendSession, isTrue);
    });

    test('Player with negative remaining sessions behaves correctly with overdraft rules', () {
      final playerExhausted = PlayerEntity(
        id: 'p-negative-1',
        userId: 'u-neg-1',
        name: 'Overdrafted Player',
        level: 'Beginner',
        category: 'Junior',
        ageGroup: 'U10',
        sessionsPaid: 8,
        sessionsAttended: 10, // -2 remaining
        isAllowedPlayer: false,
        joinDate: DateTime(2025, 1, 1),
      );

      expect(playerExhausted.remainingSessions, equals(-2));
      expect(playerExhausted.canAttendSession, isFalse);

      final playerAllowed = PlayerEntity(
        id: 'p-negative-2',
        userId: 'u-neg-2',
        name: 'Permitted Overdraft Player',
        level: 'Beginner',
        category: 'Junior',
        ageGroup: 'U10',
        sessionsPaid: 8,
        sessionsAttended: 10, // -2 remaining
        isAllowedPlayer: true,
        joinDate: DateTime(2025, 1, 1),
      );

      expect(playerAllowed.remainingSessions, equals(-2));
      expect(playerAllowed.canAttendSession, isTrue);
    });
  });
}
