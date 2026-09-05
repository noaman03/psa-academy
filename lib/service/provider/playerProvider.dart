import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PlayerProvider with ChangeNotifier {
  String _playerName = '';
  int _balance = 0;
  int _sessionsPaid = 0;
  int _sessionsAttended = 0;
  int sessionPrice = 100;
  List<dynamic> _history = [];
  String get playername => _playerName;
  String _name = '';
  String get name => _name;
  int get sessionsPaid => _sessionsPaid;
  int get balance => _balance;
  List<dynamic> get history => _history;
  int get sessionsAttended => _sessionsAttended;

  Future<void> loadPlayerName() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('players').doc(uid).get();
      if (adminSnapshot.exists) {
        _playerName = adminSnapshot['name'] ?? '[player]';
        notifyListeners();
      } else {
        print('coachg document does not exist');
      }
    } catch (e) {
      print('Failed to load admin name: $e');
    }
  }

  //load player data
  Future<void> loadPlayerData(String uid) async {
    try {
      DocumentSnapshot player =
          await FirebaseFirestore.instance.collection('players').doc(uid).get();
      if (player.exists) {
        _balance = player['balance'] ?? 0;
        _name = player['name'] ?? '';
        _history = player['history'] ?? [];
        _sessionsPaid = player['sessionsPaid'] ?? 0;
        _sessionsAttended = player['sessionsAttended'] ?? 0;

        notifyListeners();
      } else {
        print('Player document does not exist');
      }
    } catch (e) {
      print('Error loading player data: $e');
    }
  }

  //no need for this part at all
  //mark player attendance
  Future<void> attendSession(String uid) async {
    try {
      if (_sessionsPaid > _sessionsAttended) {
        _sessionsAttended++;
        _balance -= sessionPrice;
        await updatePlayerData(uid);
        notifyListeners();
      } else {
        print('Not enough paid sessions to attend');
      }
    } catch (e) {
      print('Error marking attendance: $e');
    }
  }

  //update player data
  Future<void> updatePlayerData(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('players').doc(uid).update({
        'balance': _balance,
        'history': FieldValue.arrayUnion([
          {"date": DateTime.now().toIso8601String(), "type": "attendance"}
        ])
      });
    } catch (e) {
      print('Error updating player data: $e');
    }
  }
}
