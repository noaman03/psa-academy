import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/utils/migration/firestore_v2_migration.dart';

void main() {
  group('Migration Dry-Run & Audit Log Tests', () {
    test('MigrationItemLog serializes correctly to map', () {
      const log = MigrationItemLog(
        collection: 'players',
        docId: 'p123',
        legacySchemaVersion: 1,
        fieldsDetected: ['sessionPaid', 'paymentBalance', 'password'],
        action: 'simulate_migrate',
        before: {'sessionPaid': 5, 'sessionsAttended': 3, 'password': 'secret123'},
        after: {'sessionsPaid': 8, 'sessionsAttended': 3, 'schemaVersion': 2},
        reasonForChange: 'Legacy schema reconciliation',
        warnings: ['Password field flagged for deletion'],
      );

      final map = log.toMap();
      expect(map['collection'], equals('players'));
      expect(map['docId'], equals('p123'));
      expect(map['legacySchemaVersion'], equals(1));
      expect(map['fieldsDetected'], contains('sessionPaid'));
      expect(map['fieldsDetected'], contains('password'));
      expect(map['warnings'], contains('Password field flagged for deletion'));
      expect(map['after']['schemaVersion'], equals(2));
      expect(map['after']['sessionsPaid'], equals(8));
      expect(map['after'], isNot(contains('password')));
    });

    test('MigrationSummary formats readable dry-run report', () {
      const summary = MigrationSummary(
        totalScanned: 25,
        totalNeedingMigration: 12,
        totalMigrated: 12,
        totalSkipped: 13,
        totalWarnings: 2,
        totalErrors: 0,
        isDryRun: true,
        logs: [],
      );

      final str = summary.toString();
      expect(str, contains('DRY RUN (No data written)'));
      expect(str, contains('Total Scanned: 25'));
      expect(str, contains('Needing Migration: 12'));
      expect(str, contains('Skipped (Already V2): 13'));
      expect(str, contains('Warnings Flagged: 2'));
      expect(str, contains('Errors Flagged: 0'));
    });
  });
}
