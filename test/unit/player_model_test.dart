import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/data/models/player_model.dart';

void main() {
  group('PlayerModel', () {
    test('parses modern schema correctly', () {
      final json = {
        'id': 'player_123',
        'userId': 'u_123',
        'name': 'Ahmed Ali',
        'email': 'ahmed@psa.com',
        'phone': '01000000000',
        'role': 'player',
        'isAllowedPlayer': true,
        'sessionsPaid': 10,
        'balance': 1000.0,
        'category': 'Football Academy',
        'level': 'Intermediate',
        'ageGroup': 'U16',
        'dateOfBirth': Timestamp.fromDate(DateTime(2010, 5, 12)),
        'joinDate': Timestamp.fromDate(DateTime(2025, 1, 1)),
      };

      final model = PlayerModel.fromJson(json, 'player_123');

      expect(model.id, equals('player_123'));
      expect(model.name, equals('Ahmed Ali'));
      expect(model.sessionsPaid, equals(10));
      expect(model.balance, equals(1000.0));
      expect(model.isAllowedPlayer, isTrue);
    });

    test('handles legacy schema variations (sessionPaid typo, paymentBalance, uid)', () {
      final legacyJson = {
        'uid': 'legacy_player_456',
        'name': 'Legacy Player',
        'email': 'legacy@psa.com',
        'phoneNumber': '01222222222',
        'sessionPaid': '8', // Note: singular typo and string format in legacy
        'paymentBalance': '800', // Note: legacy balance key as string
        'isAllowedPlayer': 'true',
        'category': 'Physical Fitness',
        'birthDate': '2012-04-10T00:00:00.000Z',
      };

      final model = PlayerModel.fromJson(legacyJson, 'legacy_player_456');

      expect(model.id, equals('legacy_player_456'));
      expect(model.name, equals('Legacy Player'));
      expect(model.sessionsPaid, equals(8));
      expect(model.balance, equals(800.0));
      expect(model.isAllowedPlayer, isTrue);
      expect(model.phone, equals('01222222222'));
    });

    test('toJson produces modern schema keys', () {
      final model = PlayerModel(
        id: 'p1',
        userId: 'u1',
        name: 'Player One',
        email: 'p1@psa.com',
        phone: '01000000001',
        level: 'Intermediate',
        category: 'Fitness',
        ageGroup: 'U16',
        isAllowedPlayer: true,
        sessionsPaid: 6,
        balance: 600.0,
        dateOfBirth: DateTime(2011, 2, 3),
        joinDate: DateTime(2026, 1, 1),
      );

      final json = model.toJson();

      expect(json['sessionsPaid'], equals(6));
      expect(json['balance'], equals(600.0));
      expect(json['name'], equals('Player One'));
      expect(json.containsKey('sessionPaid'), isFalse); // Old typo eliminated
    });
  });
}
