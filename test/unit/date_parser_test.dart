import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/utils/date_parser.dart';

void main() {
  group('DateParser', () {
    test('parses DateTime object directly', () {
      final now = DateTime(2026, 9, 5, 14, 30);
      final result = DateParser.parse(now);
      expect(result, equals(now));
    });

    test('parses Firestore Timestamp correctly', () {
      final now = DateTime(2026, 9, 5, 14, 30);
      final timestamp = Timestamp.fromDate(now);
      final result = DateParser.parse(timestamp);
      expect(result.year, equals(2026));
      expect(result.month, equals(9));
      expect(result.day, equals(5));
    });

    test('parses ISO-8601 string correctly', () {
      const isoString = '2026-09-05T14:30:00.000Z';
      final result = DateParser.parse(isoString);
      expect(result.year, equals(2026));
      expect(result.month, equals(9));
      expect(result.day, equals(5));
    });

    test('parses slash date string YYYY/MM/DD', () {
      const slashString = '2026/09/05';
      final result = DateParser.parse(slashString);
      expect(result.year, equals(2026));
      expect(result.month, equals(9));
      expect(result.day, equals(5));
    });

    test('falls back to default fallback date on null or invalid format', () {
      final fallback = DateTime(2020, 1, 1);
      expect(DateParser.parse(null, fallback: fallback), equals(fallback));
      expect(DateParser.parse('not-a-date', fallback: fallback), equals(fallback));
      expect(DateParser.parse(12345, fallback: fallback), equals(fallback));
    });

    test('parseNullable returns null when value is null or invalid', () {
      expect(DateParser.parseNullable(null), isNull);
      expect(DateParser.parseNullable('invalid-date'), isNull);
      expect(DateParser.parseNullable(42), isNull);
    });
  });
}
