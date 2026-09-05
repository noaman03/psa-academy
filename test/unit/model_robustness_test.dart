import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/utils/date_parser.dart';
import 'package:psa_academy/data/models/coach_model.dart';
import 'package:psa_academy/data/models/training_template_model.dart';

void main() {
  group('Model Robustness & Schema Tolerance Tests', () {
    test('DateParser safely handles null, DateTime, string, and malformed types', () {
      final now = DateTime(2026, 1, 15, 10, 30);

      // DateTime passthrough
      expect(parseSafeDateTime(now), equals(now));

      // ISO-8601 string
      expect(parseSafeDateTime('2026-01-15T10:30:00.000'), equals(DateTime(2026, 1, 15, 10, 30)));

      // Null handling
      expect(parseSafeDateTime(null), isNull);
      expect(parseRequiredDateTime(null, now), equals(now));

      // Malformed / unparseable string fallback
      expect(parseSafeDateTime('invalid-date-string'), isNull);
      expect(parseRequiredDateTime('invalid-date-string', now), equals(now));
    });

    test('CoachModel copyWith and property defaults', () {
      final coach = CoachModel(
        id: 'c-1',
        userId: 'u-c-1',
        name: 'Captain Tarek',
        specialization: 'Goalkeeping',
        joinDate: DateTime(2025, 6, 1),
        hourlyRate: 75.0,
        totalWorkedHours: 120.5,
      );

      expect(coach.name, equals('Captain Tarek'));
      expect(coach.hourlyRate, equals(75.0));
      expect(coach.totalWorkedHours, equals(120.5));
      expect(coach.isAllowedCoach, isTrue);

      final updated = coach.copyWith(hourlyRate: 90.0, totalWorkedHours: 130.0);
      expect(updated.hourlyRate, equals(90.0));
      expect(updated.totalWorkedHours, equals(130.0));
      expect(updated.name, equals('Captain Tarek'));
    });

    test('TrainingTemplateModel parses drill structure correctly', () {
      final drillMap = {
        'id': 'drill-1',
        'trainingName': 'Agility Ladder',
        'category': 'Agility',
        'description': 'Speed and footwork drill',
        'exercises': [
          {'exerciseName': 'In-and-Outs', 'sets': '3', 'reps': '10'},
          {'exerciseName': 'Lateral Hops', 'sets': '3', 'reps': '12'},
        ],
      };

      final template = TrainingTemplateModel.fromJson(drillMap, 'drill-1');
      expect(template.id, equals('drill-1'));
      expect(template.trainingName, equals('Agility Ladder'));
      expect(template.exercises.length, equals(2));
      expect(template.exercises.first.exerciseName, equals('In-and-Outs'));
    });
  });
}
