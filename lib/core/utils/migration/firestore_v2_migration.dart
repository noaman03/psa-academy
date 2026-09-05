import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../date_parser.dart';

/// Comprehensive, safe, idempotent database migration tool for PSA Academy V2.
class MigrationItemLog {
  final String collection;
  final String docId;
  final String action;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final String? error;

  const MigrationItemLog({
    required this.collection,
    required this.docId,
    required this.action,
    required this.before,
    required this.after,
    this.error,
  });
}

class MigrationSummary {
  final int totalScanned;
  final int totalNeedingMigration;
  final int totalMigrated;
  final int totalSkipped;
  final int totalErrors;
  final bool isDryRun;
  final List<MigrationItemLog> logs;

  const MigrationSummary({
    required this.totalScanned,
    required this.totalNeedingMigration,
    required this.totalMigrated,
    required this.totalSkipped,
    required this.totalErrors,
    required this.isDryRun,
    required this.logs,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== PSA Academy V2 Database Migration Summary ===');
    buffer.writeln('Mode: ${isDryRun ? "DRY RUN (No data written)" : "LIVE MIGRATION"}');
    buffer.writeln('Total Scanned: $totalScanned');
    buffer.writeln('Needing Migration: $totalNeedingMigration');
    buffer.writeln('Successfully Migrated: $totalMigrated');
    buffer.writeln('Skipped (Already V2): $totalSkipped');
    buffer.writeln('Errors Encountered: $totalErrors');
    buffer.writeln('==================================================');
    return buffer.toString();
  }
}

class FirestoreV2Migration {
  final FirebaseFirestore _firestore;

  FirestoreV2Migration([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Run all collection migrations. Defaults to safe dryRun = true.
  Future<MigrationSummary> runAllMigrations({bool dryRun = true}) async {
    final logs = <MigrationItemLog>[];
    int scanned = 0;
    int needingMigration = 0;
    int migrated = 0;
    int skipped = 0;
    int errors = 0;

    // 1. Migrate Players
    final playerSummary = await migratePlayers(dryRun: dryRun);
    scanned += playerSummary.totalScanned;
    needingMigration += playerSummary.totalNeedingMigration;
    migrated += playerSummary.totalMigrated;
    skipped += playerSummary.totalSkipped;
    errors += playerSummary.totalErrors;
    logs.addAll(playerSummary.logs);

    // 2. Migrate Coaches
    final coachSummary = await migrateCoaches(dryRun: dryRun);
    scanned += coachSummary.totalScanned;
    needingMigration += coachSummary.totalNeedingMigration;
    migrated += coachSummary.totalMigrated;
    skipped += coachSummary.totalSkipped;
    errors += coachSummary.totalErrors;
    logs.addAll(coachSummary.logs);

    // 3. Migrate Training Templates
    final templateSummary = await migrateTemplates(dryRun: dryRun);
    scanned += templateSummary.totalScanned;
    needingMigration += templateSummary.totalNeedingMigration;
    migrated += templateSummary.totalMigrated;
    skipped += templateSummary.totalSkipped;
    errors += templateSummary.totalErrors;
    logs.addAll(templateSummary.logs);

    return MigrationSummary(
      totalScanned: scanned,
      totalNeedingMigration: needingMigration,
      totalMigrated: migrated,
      totalSkipped: skipped,
      totalErrors: errors,
      isDryRun: dryRun,
      logs: logs,
    );
  }

  /// Migrate players collection:
  /// - sessionPaid typo -> sessionsPaid
  /// - paymentBalance -> balance
  /// - uid -> userId
  /// - cumulative lifetime calculation: sessionsPaid = rawPaid + sessionsAttended
  /// - normalize dates to Timestamp
  /// - set schemaVersion = 2
  Future<MigrationSummary> migratePlayers({bool dryRun = true}) async {
    final logs = <MigrationItemLog>[];
    int scanned = 0;
    int needingMigration = 0;
    int migrated = 0;
    int skipped = 0;
    int errors = 0;

    try {
      final snapshot = await _firestore.collection('players').get();
      scanned = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final int schemaVersion = (data['schemaVersion'] as num?)?.toInt() ?? 1;

        if (schemaVersion >= 2) {
          skipped++;
          continue;
        }

        needingMigration++;
        final before = Map<String, dynamic>.from(data);
        final patch = <String, dynamic>{};

        try {
          // 1. Session accounting
          final rawPaid = data['sessionsPaid'] ?? data['sessionPaid'] ?? 0;
          final int rawPaidInt = rawPaid is num ? rawPaid.toInt() : (int.tryParse(rawPaid.toString()) ?? 0);
          final rawAttended = data['sessionsAttended'] ?? 0;
          final int currentAttended = rawAttended is num ? rawAttended.toInt() : (int.tryParse(rawAttended.toString()) ?? 0);
          final int lifetimePaid = rawPaidInt + currentAttended;

          patch['sessionsPaid'] = lifetimePaid;
          patch['sessionsAttended'] = currentAttended;

          // 2. Financial balance
          final rawBal = data['balance'] ?? data['paymentBalance'] ?? 0;
          final double balance = rawBal is num ? rawBal.toDouble() : (double.tryParse(rawBal.toString()) ?? 0.0);
          patch['balance'] = balance;

          // 3. User ID
          final String userId = (data['userId'] ?? data['uid'] ?? doc.id).toString();
          patch['userId'] = userId;

          // 4. Normalized timestamps
          if (data['joinDate'] != null && data['joinDate'] is! Timestamp) {
            final parsed = DateParser.parse(data['joinDate']);
            patch['joinDate'] = Timestamp.fromDate(parsed);
          }
          if (data['dateOfBirth'] != null && data['dateOfBirth'] is! Timestamp) {
            final parsed = DateParser.parseNullable(data['dateOfBirth']);
            if (parsed != null) patch['dateOfBirth'] = Timestamp.fromDate(parsed);
          }
          if (data['lastAttendance'] != null && data['lastAttendance'] is! Timestamp) {
            final parsed = DateParser.parseNullable(data['lastAttendance']);
            if (parsed != null) patch['lastAttendance'] = Timestamp.fromDate(parsed);
          }

          // 5. Canonical flags
          patch['schemaVersion'] = 2;
          patch['isAllowedPlayer'] = data['isAllowedPlayer'] is bool ? data['isAllowedPlayer'] : true;
          patch['isActive'] = data['isActive'] is bool ? data['isActive'] : true;

          if (!dryRun) {
            await _firestore.collection('players').doc(doc.id).update(patch);
          }

          migrated++;
          logs.add(MigrationItemLog(
            collection: 'players',
            docId: doc.id,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
          ));
        } catch (e) {
          errors++;
          logs.add(MigrationItemLog(
            collection: 'players',
            docId: doc.id,
            action: 'ERROR',
            before: before,
            after: {},
            error: e.toString(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Players collection scan failed: $e');
    }

    return MigrationSummary(
      totalScanned: scanned,
      totalNeedingMigration: needingMigration,
      totalMigrated: migrated,
      totalSkipped: skipped,
      totalErrors: errors,
      isDryRun: dryRun,
      logs: logs,
    );
  }

  /// Migrate coaches collection:
  /// - working hours -> totalWorkedHours
  /// - salaryPerHour / hourlyRate
  /// - isAllowed -> isAllowedCoach
  Future<MigrationSummary> migrateCoaches({bool dryRun = true}) async {
    final logs = <MigrationItemLog>[];
    int scanned = 0;
    int needingMigration = 0;
    int migrated = 0;
    int skipped = 0;
    int errors = 0;

    try {
      final snapshot = await _firestore.collection('coaches').get();
      scanned = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final int schemaVersion = (data['schemaVersion'] as num?)?.toInt() ?? 1;

        if (schemaVersion >= 2) {
          skipped++;
          continue;
        }

        needingMigration++;
        final before = Map<String, dynamic>.from(data);
        final patch = <String, dynamic>{};

        try {
          final rawHours = data['totalWorkedHours'] ?? data['working hours'] ?? 0.0;
          patch['totalWorkedHours'] = rawHours is num ? rawHours.toDouble() : (double.tryParse(rawHours.toString()) ?? 0.0);

          final rawRate = data['hourlyRate'] ?? data['salaryPerHour'] ?? 50.0;
          patch['hourlyRate'] = rawRate is num ? rawRate.toDouble() : (double.tryParse(rawRate.toString()) ?? 50.0);

          patch['isAllowedCoach'] = data['isAllowedCoach'] ?? data['isAllowed'] ?? true;
          patch['schemaVersion'] = 2;

          if (!dryRun) {
            await _firestore.collection('coaches').doc(doc.id).update(patch);
          }

          migrated++;
          logs.add(MigrationItemLog(
            collection: 'coaches',
            docId: doc.id,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
          ));
        } catch (e) {
          errors++;
          logs.add(MigrationItemLog(
            collection: 'coaches',
            docId: doc.id,
            action: 'ERROR',
            before: before,
            after: {},
            error: e.toString(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Coaches collection scan failed: $e');
    }

    return MigrationSummary(
      totalScanned: scanned,
      totalNeedingMigration: needingMigration,
      totalMigrated: migrated,
      totalSkipped: skipped,
      totalErrors: errors,
      isDryRun: dryRun,
      logs: logs,
    );
  }

  /// Migrate trainingTemplates collection:
  /// - Sanitize trailing whitespace in 'trainingName ' -> 'trainingName'
  /// - Sanitize 'description ' -> 'description'
  Future<MigrationSummary> migrateTemplates({bool dryRun = true}) async {
    final logs = <MigrationItemLog>[];
    int scanned = 0;
    int needingMigration = 0;
    int migrated = 0;
    int skipped = 0;
    int errors = 0;

    try {
      final snapshot = await _firestore.collection('trainingTemplates').get();
      scanned = snapshot.docs.length;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final hasTrailingSpaceName = data.containsKey('trainingName ');
        final hasTrailingSpaceDesc = data.containsKey('description ');

        if (!hasTrailingSpaceName && !hasTrailingSpaceDesc && data['schemaVersion'] == 2) {
          skipped++;
          continue;
        }

        needingMigration++;
        final before = Map<String, dynamic>.from(data);
        final patch = <String, dynamic>{};

        try {
          final String name = (data['trainingName'] ?? data['trainingName '] ?? '').toString().trim();
          final String desc = (data['description'] ?? data['description '] ?? '').toString().trim();

          patch['trainingName'] = name;
          patch['description'] = desc;
          patch['schemaVersion'] = 2;

          if (!dryRun) {
            await _firestore.collection('trainingTemplates').doc(doc.id).update(patch);
          }

          migrated++;
          logs.add(MigrationItemLog(
            collection: 'trainingTemplates',
            docId: doc.id,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
          ));
        } catch (e) {
          errors++;
          logs.add(MigrationItemLog(
            collection: 'trainingTemplates',
            docId: doc.id,
            action: 'ERROR',
            before: before,
            after: {},
            error: e.toString(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Templates collection scan failed: $e');
    }

    return MigrationSummary(
      totalScanned: scanned,
      totalNeedingMigration: needingMigration,
      totalMigrated: migrated,
      totalSkipped: skipped,
      totalErrors: errors,
      isDryRun: dryRun,
      logs: logs,
    );
  }
}
