import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coach_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreCoachDataSource {
  final FirebaseFirestore firestore;

  FirestoreCoachDataSource(this.firestore);

  /// Get coach by ID
  Future<CoachModel> getCoachById(String coachId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .get();

      if (!doc.exists) {
        throw Exception('Coach not found');
      }

      return CoachModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get coach: $e');
    }
  }

  /// Get coach by user ID
  Future<CoachModel> getCoachByUserId(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Coach not found for user ID: $userId');
      }

      return CoachModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get coach by user ID: $e');
    }
  }

  /// Create new coach
  Future<CoachModel> createCoach(CoachModel coach) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.coachesCollection)
          .add(coach.toFirestore());

      final doc = await docRef.get();
      return CoachModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create coach: $e');
    }
  }

  /// Update existing coach
  Future<CoachModel> updateCoach(CoachModel coach) async {
    try {
      if (coach.id.isEmpty) {
        throw Exception('Coach ID is required for update');
      }

      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coach.id)
          .update(coach.toFirestore());

      return await getCoachById(coach.id);
    } catch (e) {
      throw Exception('Failed to update coach: $e');
    }
  }

  /// Delete coach
  Future<void> deleteCoach(String coachId) async {
    try {
      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete coach: $e');
    }
  }

  /// Get all coaches
  Future<List<CoachModel>> getAllCoaches() async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => CoachModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all coaches: $e');
    }
  }

  /// Get coaches by specialization
  Future<List<CoachModel>> getCoachesBySpecialization(
    String specialization,
  ) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .where('specialization', isEqualTo: specialization)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => CoachModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get coaches by specialization: $e');
    }
  }

  /// Get active coaches
  Future<List<CoachModel>> getActiveCoaches() async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => CoachModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active coaches: $e');
    }
  }

  /// Get coaches available on specific day
  Future<List<CoachModel>> getCoachesAvailableOn(String day) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .where('availability', arrayContains: day)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => CoachModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get coaches available on $day: $e');
    }
  }

  /// Search coaches by name
  Future<List<CoachModel>> searchCoachesByName(String name) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.coachesCollection)
          .orderBy('name')
          .startAt([name]).endAt([name + '\uf8ff']).get();

      return snapshot.docs.map((doc) => CoachModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search coaches by name: $e');
    }
  }

  /// Update coach rating
  Future<CoachModel> updateCoachRating(String coachId, double rating) async {
    try {
      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .update({'rating': rating});

      return await getCoachById(coachId);
    } catch (e) {
      throw Exception('Failed to update coach rating: $e');
    }
  }

  /// Update coach availability
  Future<CoachModel> updateCoachAvailability(
    String coachId,
    List<String> availability,
  ) async {
    try {
      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .update({'availability': availability});

      return await getCoachById(coachId);
    } catch (e) {
      throw Exception('Failed to update coach availability: $e');
    }
  }

  /// Update coach status
  Future<CoachModel> updateCoachStatus(String coachId, bool isActive) async {
    try {
      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .update({'isActive': isActive});

      return await getCoachById(coachId);
    } catch (e) {
      throw Exception('Failed to update coach status: $e');
    }
  }

  /// Update coach session count
  Future<CoachModel> updateSessionCount(String coachId, int count) async {
    try {
      await firestore
          .collection(AppConstants.coachesCollection)
          .doc(coachId)
          .update({'sessionCount': count});

      return await getCoachById(coachId);
    } catch (e) {
      throw Exception('Failed to update coach session count: $e');
    }
  }
}
