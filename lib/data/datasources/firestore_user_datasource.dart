import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSource(this._firestore);

  /// Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get user by email
  Future<UserModel> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Create user
  Future<UserModel> createUser(UserModel user) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.usersCollection).doc(user.id);

      await docRef.set(user.toFirestore());

      final doc = await docRef.get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update user
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.usersCollection).doc(user.id);

      await docRef.update(user.toFirestore());

      final doc = await docRef.get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }

  /// Update user status
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }
}
