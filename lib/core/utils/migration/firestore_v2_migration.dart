import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../date_parser.dart';

/// Detailed audit item for migration dry-run and execution.
class MigrationItemLog {
  final String collection;
  final String docId;
  final int legacySchemaVersion;
  final List<String> fieldsDetected;
  final String action;
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final String reasonForChange;
  final List<String> warnings;
  final String? error;

  const MigrationItemLog({
    required this.collection,
    required this.docId,
    required this.legacySchemaVersion,
    required this.fieldsDetected,
    required this.action,
    required this.before,
    required this.after,
    required this.reasonForChange,
    this.warnings = const [],
    this.error,
  });

  Map<String, dynamic> toMap() {
    return {
      'collection': collection,
      'docId': docId,
      'legacySchemaVersion': legacySchemaVersion,
      'fieldsDetected': fieldsDetected,
      'action': action,
      'reasonForChange': reasonForChange,
      'warnings': warnings,
      'error': error,
      'before': before,
      'after': after,
    };
  }
}

class MigrationSummary {
  final int totalScanned;
  final int totalNeedingMigration;
  final int totalMigrated;
  final int totalSkipped;
  final int totalWarnings;
  final int totalErrors;
  final bool isDryRun;
  final List<MigrationItemLog> logs;

  const MigrationSummary({
    required this.totalScanned,
    required this.totalNeedingMigration,
    required this.totalMigrated,
    required this.totalSkipped,
    required this.totalWarnings,
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
    buffer.writeln('Successfully Migrated / Simulated: $totalMigrated');
    buffer.writeln('Skipped (Already V2): $totalSkipped');
    buffer.writeln('Warnings Flagged: $totalWarnings');
    buffer.writeln('Errors Flagged: $totalErrors');
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
    int warnings = 0;
    int errors = 0;

    // 1. Migrate Players
    final playerSummary = await migratePlayers(dryRun: dryRun);
    scanned += playerSummary.totalScanned;
    needingMigration += playerSummary.totalNeedingMigration;
    migrated += playerSummary.totalMigrated;
    skipped += playerSummary.totalSkipped;
    warnings += playerSummary.totalWarnings;
    errors += playerSummary.totalErrors;
    logs.addAll(playerSummary.logs);

    // 2. Migrate Coaches
    final coachSummary = await migrateCoaches(dryRun: dryRun);
    scanned += coachSummary.totalScanned;
    needingMigration += coachSummary.totalNeedingMigration;
    migrated += coachSummary.totalMigrated;
    skipped += coachSummary.totalSkipped;
    warnings += coachSummary.totalWarnings;
    errors += coachSummary.totalErrors;
    logs.addAll(coachSummary.logs);

    // 3. Migrate Training Templates
    final templateSummary = await migrateTemplates(dryRun: dryRun);
    scanned += templateSummary.totalScanned;
    needingMigration += templateSummary.totalNeedingMigration;
    migrated += templateSummary.totalMigrated;
    skipped += templateSummary.totalSkipped;
    warnings += templateSummary.totalWarnings;
    errors += templateSummary.totalErrors;
    logs.addAll(templateSummary.logs);

    return MigrationSummary(
      totalScanned: scanned,
      totalNeedingMigration: needingMigration,
      totalMigrated: migrated,
      totalSkipped: skipped,
      totalWarnings: warnings,
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
    int warningsCount = 0;
    int errorsCount = 0;

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
        final detectedFields = data.keys.toList();
        final warnings = <String>[];
        final reasons = <String>[];

        try {
          // Validation: User ID
          final rawUserId = data['userId'] ?? data['uid'] ?? doc.id;
          final String userId = rawUserId.toString().trim();
          if (userId.isEmpty) {
            throw Exception('Corrupted record: document has empty userId');
          }
          if (data['userId'] == null) {
            patch['userId'] = userId;
            reasons.add('Normalized uid to userId');
          }

          // 1. Session accounting
          final rawPaid = data['sessionsPaid'] ?? data['sessionPaid'];
          if (data.containsKey('sessionPaid')) {
            reasons.add('Migrated legacy typo sessionPaid to sessionsPaid');
          }

          int rawPaidInt = 0;
          if (rawPaid is num) {
            rawPaidInt = rawPaid.toInt();
          } else if (rawPaid != null) {
            final parsed = int.tryParse(rawPaid.toString());
            if (parsed == null) {
              warnings.add('Unparseable sessionsPaid value "$rawPaid", defaulted to 0');
            } else {
              rawPaidInt = parsed;
              reasons.add('Converted string sessionsPaid to integer');
            }
          }

          final rawAttended = data['sessionsAttended'] ?? 0;
          int currentAttended = 0;
          if (rawAttended is num) {
            currentAttended = rawAttended.toInt();
          } else {
            final parsed = int.tryParse(rawAttended.toString());
            if (parsed == null) {
              warnings.add('Unparseable sessionsAttended value "$rawAttended", defaulted to 0');
            } else {
              currentAttended = parsed;
              reasons.add('Converted string sessionsAttended to integer');
            }
          }

          if (currentAttended < 0) {
            warnings.add('Negative sessionsAttended detected ($currentAttended)');
          }

          final int lifetimePaid = rawPaidInt + currentAttended;
          if (lifetimePaid < 0) {
            warnings.add('Negative lifetime sessionsPaid computed ($lifetimePaid)');
          } else if (lifetimePaid > 1000) {
            warnings.add('Implausibly high lifetime sessionsPaid ($lifetimePaid)');
          }

          patch['sessionsPaid'] = lifetimePaid;
          patch['sessionsAttended'] = currentAttended;
          reasons.add('Reconciled remaining sessions to lifetime paid ($rawPaidInt + $currentAttended = $lifetimePaid)');

          // 2. Financial balance
          final rawBal = data['balance'] ?? data['paymentBalance'];
          if (data.containsKey('paymentBalance')) {
            reasons.add('Migrated legacy key paymentBalance to balance');
          }

          double balance = 0.0;
          if (rawBal is num) {
            balance = rawBal.toDouble();
          } else if (rawBal != null) {
            final parsed = double.tryParse(rawBal.toString());
            if (parsed == null) {
              warnings.add('Unparseable balance value "$rawBal", defaulted to 0.0');
            } else {
              balance = parsed;
              reasons.add('Converted string balance to double');
            }
          }
          patch['balance'] = balance;

          // 3. Normalized timestamps
          if (data['joinDate'] != null && data['joinDate'] is! Timestamp) {
            final parsed = DateParser.parse(data['joinDate']);
            patch['joinDate'] = Timestamp.fromDate(parsed);
            reasons.add('Normalized joinDate string to Timestamp');
          }
          if (data['dateOfBirth'] != null && data['dateOfBirth'] is! Timestamp) {
            final parsed = DateParser.parseNullable(data['dateOfBirth']);
            if (parsed != null) {
              patch['dateOfBirth'] = Timestamp.fromDate(parsed);
              reasons.add('Normalized dateOfBirth string to Timestamp');
            }
          }
          if (data['lastAttendance'] != null && data['lastAttendance'] is! Timestamp) {
            final parsed = DateParser.parseNullable(data['lastAttendance']);
            if (parsed != null) {
              patch['lastAttendance'] = Timestamp.fromDate(parsed);
              reasons.add('Normalized lastAttendance string to Timestamp');
            }
          }

          // 4. Canonical flags
          patch['schemaVersion'] = 2;
          patch['isAllowedPlayer'] = data['isAllowedPlayer'] is bool ? data['isAllowedPlayer'] : true;
          patch['isActive'] = data['isActive'] is bool ? data['isActive'] : true;

          if (!dryRun) {
            await _firestore.collection('players').doc(doc.id).update(patch);
          }

          migrated++;
          if (warnings.isNotEmpty) warningsCount++;

          logs.add(MigrationItemLog(
            collection: 'players',
            docId: doc.id,
            legacySchemaVersion: schemaVersion,
            fieldsDetected: detectedFields,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
            reasonForChange: reasons.join('; '),
            warnings: warnings,
          ));
        } catch (e) {
          errorsCount++;
          logs.add(MigrationItemLog(
            collection: 'players',
            docId: doc.id,
            legacySchemaVersion: schemaVersion,
            fieldsDetected: detectedFields,
            action: 'ERROR',
            before: before,
            after: {},
            reasonForChange: 'Failed migration validation',
            warnings: warnings,
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
      totalWarnings: warningsCount,
      totalErrors: errorsCount,
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
    int warningsCount = 0;
    int errorsCount = 0;

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
        final detectedFields = data.keys.toList();
        final warnings = <String>[];
        final reasons = <String>[];

        try {
          final rawHours = data['totalWorkedHours'] ?? data['working hours'] ?? 0.0;
          if (data.containsKey('working hours')) {
            reasons.add('Normalized legacy space key "working hours" to totalWorkedHours');
          }
          final double workedHours = rawHours is num ? rawHours.toDouble() : (double.tryParse(rawHours.toString()) ?? 0.0);
          if (workedHours < 0) {
            warnings.add('Negative workedHours detected ($workedHours)');
          }
          patch['totalWorkedHours'] = workedHours;

          final rawRate = data['hourlyRate'] ?? data['salaryPerHour'] ?? 50.0;
          if (data.containsKey('salaryPerHour')) {
            reasons.add('Normalized salaryPerHour to hourlyRate');
          }
          final double hourlyRate = rawRate is num ? rawRate.toDouble() : (double.tryParse(rawRate.toString()) ?? 50.0);
          if (hourlyRate <= 0) {
            warnings.add('Zero or negative hourlyRate ($hourlyRate)');
          }
          patch['hourlyRate'] = hourlyRate;

          patch['isAllowedCoach'] = data['isAllowedCoach'] ?? data['isAllowed'] ?? true;
          patch['schemaVersion'] = 2;

          if (!dryRun) {
            await _firestore.collection('coaches').doc(doc.id).update(patch);
          }

          migrated++;
          if (warnings.isNotEmpty) warningsCount++;

          logs.add(MigrationItemLog(
            collection: 'coaches',
            docId: doc.id,
            legacySchemaVersion: schemaVersion,
            fieldsDetected: detectedFields,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
            reasonForChange: reasons.join('; '),
            warnings: warnings,
          ));
        } catch (e) {
          errorsCount++;
          logs.add(MigrationItemLog(
            collection: 'coaches',
            docId: doc.id,
            legacySchemaVersion: schemaVersion,
            fieldsDetected: detectedFields,
            action: 'ERROR',
            before: before,
            after: {},
            reasonForChange: 'Failed migration validation',
            warnings: warnings,
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
      totalWarnings: warningsCount,
      totalErrors: errorsCount,
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
    int warningsCount = 0;
    int errorsCount = 0;

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
        final detectedFields = data.keys.toList();
        final warnings = <String>[];
        final reasons = <String>[];

        try {
          final String name = (data['trainingName'] ?? data['trainingName '] ?? '').toString().trim();
          final String desc = (data['description'] ?? data['description '] ?? '').toString().trim();

          if (hasTrailingSpaceName) {
            reasons.add('Sanitized trailing whitespace in "trainingName "');
          }
          if (hasTrailingSpaceDesc) {
            reasons.add('Sanitized trailing whitespace in "description "');
          }

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
            legacySchemaVersion: (data['schemaVersion'] as num?)?.toInt() ?? 1,
            fieldsDetected: detectedFields,
            action: dryRun ? 'MIGRATION_SIMULATED' : 'MIGRATED',
            before: before,
            after: {...before, ...patch},
            reasonForChange: reasons.join('; '),
            warnings: warnings,
          ));
        } catch (e) {
          errorsCount++;
          logs.add(MigrationItemLog(
            collection: 'trainingTemplates',
            docId: doc.id,
            legacySchemaVersion: 1,
            fieldsDetected: detectedFields,
            action: 'ERROR',
            before: before,
            after: {},
            reasonForChange: 'Failed template migration validation',
            warnings: warnings,
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
      totalWarnings: warningsCount,
      totalErrors: errorsCount,
      isDryRun: dryRun,
      logs: logs,
    );
  }
}
