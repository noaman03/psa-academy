import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/data/models/training_template_model.dart';

void main() {
  group('TrainingTemplateModel', () {
    test('handles legacy trailing space key "trainingName "', () {
      final json = {
        'trainingName ': 'Agility & Speed Drills', // Legacy bug has trailing space
        'category': 'Agility',
        'targetMuscle': 'Legs',
        'exercises': [
          {'exerciseName': 'Cone Shuttle', 'sets': '4', 'reps': '30s'},
          {'exerciseName': 'Ladder Steps', 'sets': '3', 'reps': '10'},
        ],
      };

      final model = TrainingTemplateModel.fromJson(json, 'template_1');

      expect(model.id, equals('template_1'));
      expect(model.trainingName, equals('Agility & Speed Drills'));
      expect(model.category, equals('Agility'));
      expect(model.exercises.length, equals(2));
      expect(model.exercises.first.exerciseName, equals('Cone Shuttle'));
    });

    test('toJson produces sanitized clean keys without trailing spaces', () {
      final json = {
        'trainingName ': 'Sanitized Routine',
        'category': 'Strength',
        'exercises': [],
      };

      final model = TrainingTemplateModel.fromJson(json, 'template_2');
      final serialized = model.toJson();

      expect(serialized.containsKey('trainingName'), isTrue);
      expect(serialized.containsKey('trainingName '), isFalse);
      expect(serialized['trainingName'], equals('Sanitized Routine'));
    });
  });
}
