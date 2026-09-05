import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';
import '../../core/constants/app_constants.dart';

class FirestorePlayerDataSource {
  final FirebaseFirestore _firestore;

  FirestorePlayerDataSource(this._firestore);

  /// Get player by ID
  Future<PlayerModel> getPlayerById(String playerId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.playersCollection)
          .doc(playerId)
          .get();

      if (!doc.exists) {
        throw Exception('Player not found');
      }

      return PlayerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get player: $e');
    }
  }

  /// Get player by user ID
  Future<PlayerModel> getPlayerByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.playersCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Player not found');
      }

      return PlayerModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get player: $e');
    }
  }

  /// Create player
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.playersCollection)
          .add(player.toFirestore());

      final doc = await docRef.get();
      return PlayerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create player: $e');
    }
  }

  /// Update player
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.playersCollection).doc(player.id);

      await docRef.update(player.toFirestore());

      final doc = await docRef.get();
      return PlayerModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update player: $e');
    }
  }

  /// Delete player
  Future<void> deletePlayer(String playerId) async {
    try {
      await _firestore
          .collection(AppConstants.playersCollection)
          .doc(playerId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete player: $e');
    }
  }

  /// Get all players
  Future<List<PlayerModel>> getAllPlayers() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConstants.playersCollection).get();

      return querySnapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get players: $e');
    }
  }

  /// Get players by category
  Future<List<PlayerModel>> getPlayersByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.playersCollection)
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get players: $e');
    }
  }

  /// Get players by level
  Future<List<PlayerModel>> getPlayersByLevel(String level) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.playersCollection)
          .where('level', isEqualTo: level)
          .get();

      return querySnapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get players: $e');
    }
  }

  /// Get active players
  Future<List<PlayerModel>> getActivePlayers() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.playersCollection)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get players: $e');
    }
  }

  /// Search players by name
  Future<List<PlayerModel>> searchPlayersByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.playersCollection)
          .orderBy('name')
          .startAt([name]).endAt(['$name\uf8ff']).get();

      return querySnapshot.docs
          .map((doc) => PlayerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search players: $e');
    }
  }

  /// Update player balance
  Future<void> updatePlayerBalance(String playerId, double balance) async {
    try {
      await _firestore
          .collection(AppConstants.playersCollection)
          .doc(playerId)
          .update({'paymentBalance': balance});
    } catch (e) {
      throw Exception('Failed to update player balance: $e');
    }
  }

  /// Update attendance count
  Future<void> updateAttendanceCount(String playerId, int count) async {
    try {
      await _firestore
          .collection(AppConstants.playersCollection)
          .doc(playerId)
          .update({'attendanceCount': count});
    } catch (e) {
      throw Exception('Failed to update attendance count: $e');
    }
  }

  /// Update player stats
  Future<void> updatePlayerStats(
      String playerId, Map<String, dynamic> stats) async {
    try {
      await _firestore
          .collection(AppConstants.playersCollection)
          .doc(playerId)
          .update({'stats': stats});
    } catch (e) {
      throw Exception('Failed to update player stats: $e');
    }
  }
}
