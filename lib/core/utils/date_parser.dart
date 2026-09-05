import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to safely parse dates stored unpredictably across legacy Firestore records.
class DateParser {
  DateParser._();

  static DateTime? parseNullable(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      // Handle slash format YYYY/MM/DD
      if (value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 3) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y != null && m != null && d != null) {
            return DateTime(y, m, d);
          }
        }
      }
      return DateTime.tryParse(value);
    }
    if (value is int && value > 100000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static DateTime parse(dynamic value, {DateTime? fallback}) {
    final parsed = parseNullable(value);
    return parsed ?? fallback ?? DateTime.now();
  }
}

// Top-level aliases for backward compatibility
DateTime? parseSafeDateTime(dynamic value) => DateParser.parseNullable(value);

DateTime parseRequiredDateTime(dynamic value, [DateTime? fallback]) =>
    DateParser.parse(value, fallback: fallback);
