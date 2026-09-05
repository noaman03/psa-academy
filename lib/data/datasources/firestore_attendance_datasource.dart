import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';
import '../../core/constants/app_constants.dart';

class FirestoreAttendanceDataSource {
  final FirebaseFirestore _firestore;

  FirestoreAttendanceDataSource(this._firestore);

  /// Get attendance by ID
  Future<AttendanceModel> getAttendanceById(String attendanceId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendanceId)
          .get();

      if (!doc.exists) {
        throw Exception('Attendance not found');
      }

      return AttendanceModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Create attendance
  Future<AttendanceModel> createAttendance(AttendanceModel attendance) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.attendanceCollection)
          .add(attendance.toFirestore());

      final doc = await docRef.get();
      return AttendanceModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create attendance: $e');
    }
  }

  /// Update attendance
  Future<AttendanceModel> updateAttendance(AttendanceModel attendance) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendance.id);

      await docRef.update(attendance.toFirestore());

      final doc = await docRef.get();
      return AttendanceModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  /// Delete attendance
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendanceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  /// Get attendance by player ID
  Future<List<AttendanceModel>> getAttendanceByPlayerId(String playerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('playerId', isEqualTo: playerId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Get attendance by coach ID
  Future<List<AttendanceModel>> getAttendanceByCoachId(String coachId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('coachId', isEqualTo: coachId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Get attendance by date range
  Future<List<AttendanceModel>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Get attendance by player and date range
  Future<List<AttendanceModel>> getPlayerAttendanceByDateRange(
    String playerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('playerId', isEqualTo: playerId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Get unseen attendance count
  Future<int> getUnseenAttendanceCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('isSeen', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unseen count: $e');
    }
  }

  /// Mark attendance as seen
  Future<void> markAttendanceAsSeen(String attendanceId) async {
    try {
      await _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendanceId)
          .update({'isSeen': true});
    } catch (e) {
      throw Exception('Failed to mark as seen: $e');
    }
  }

  /// Mark all attendance as seen
  Future<void> markAllAttendanceAsSeen() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('isSeen', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isSeen': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as seen: $e');
    }
  }

  /// Stream attendance updates
  Stream<List<AttendanceModel>> watchAttendance() {
    return _firestore
        .collection(AppConstants.attendanceCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  /// Stream unseen count
  Stream<int> watchUnseenCount() {
    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('isSeen', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
