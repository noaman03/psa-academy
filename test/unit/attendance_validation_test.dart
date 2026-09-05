import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Attendance Validation Business Rules Tests', () {
    test('Coach cannot scan themselves as player', () {
      const coachId = 'coach_123';
      const playerId = 'coach_123';

      bool wouldReject(String cId, String pId) {
        return cId.trim().isNotEmpty && cId.trim() == pId.trim();
      }

      expect(wouldReject(coachId, playerId), isTrue);
      expect(wouldReject(coachId, 'player_456'), isFalse);
    });

    test('Inactive player is rejected from attendance check-in', () {
      bool canCheckIn({required bool isActive}) {
        return isActive;
      }

      expect(canCheckIn(isActive: false), isFalse);
      expect(canCheckIn(isActive: true), isTrue);
    });

    test('Overdraft check-in rules with canonical remaining sessions', () {
      bool isAllowedCheckIn({
        required int sessionsPaid,
        required int sessionsAttended,
        required bool isAllowedPlayer,
      }) {
        final remaining = sessionsPaid - sessionsAttended;
        if (remaining <= 0 && !isAllowedPlayer) {
          return false;
        }
        return true;
      }

      // Normal player with sessions
      expect(
        isAllowedCheckIn(sessionsPaid: 10, sessionsAttended: 5, isAllowedPlayer: false),
        isTrue,
      );

      // Normal player with 0 sessions (not allowed)
      expect(
        isAllowedCheckIn(sessionsPaid: 10, sessionsAttended: 10, isAllowedPlayer: false),
        isFalse,
      );

      // VIP player with 0 sessions (allowed overdraft)
      expect(
        isAllowedCheckIn(sessionsPaid: 10, sessionsAttended: 10, isAllowedPlayer: true),
        isTrue,
      );

      // Negative balance player (allowed overdraft)
      expect(
        isAllowedCheckIn(sessionsPaid: 10, sessionsAttended: 12, isAllowedPlayer: true),
        isTrue,
      );

      // Negative balance player (not allowed overdraft)
      expect(
        isAllowedCheckIn(sessionsPaid: 10, sessionsAttended: 12, isAllowedPlayer: false),
        isFalse,
      );
    });

    test('Duplicate check-in protection within 15-minute window', () {
      final now = DateTime(2026, 3, 5, 14, 30);

      bool isDuplicate(DateTime? lastAttendance, DateTime currentScan) {
        if (lastAttendance == null) return false;
        final diff = currentScan.difference(lastAttendance);
        return diff.inMinutes < 15 && diff.inMinutes >= 0;
      }

      // First attendance ever
      expect(isDuplicate(null, now), isFalse);

      // Attended 5 minutes ago -> duplicate!
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      expect(isDuplicate(fiveMinutesAgo, now), isTrue);

      // Attended 14 minutes ago -> duplicate!
      final fourteenMinutesAgo = now.subtract(const Duration(minutes: 14));
      expect(isDuplicate(fourteenMinutesAgo, now), isTrue);

      // Attended 16 minutes ago -> permitted!
      final sixteenMinutesAgo = now.subtract(const Duration(minutes: 16));
      expect(isDuplicate(sixteenMinutesAgo, now), isFalse);

      // Attended yesterday -> permitted!
      final yesterday = now.subtract(const Duration(days: 1));
      expect(isDuplicate(yesterday, now), isFalse);
    });
  });
}
