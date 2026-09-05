import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  String _adminName = '';
  final List<Map<String, dynamic>> _reportsAttendance = [];
  List<Map<String, dynamic>> _reportsPayments = [];
  final List<Map<String, dynamic>> _reportsExpences = [];

  String get adminName => _adminName;
  List<Map<String, dynamic>> get reportsAttendace => _reportsAttendance;
  List<Map<String, dynamic>> get reportsPayments => _reportsPayments;
  List<Map<String, dynamic>> get reportsExpences => _reportsExpences;

  Future<void> loadAdminName() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('admin').doc(uid).get();
      if (adminSnapshot.exists) {
        _adminName = adminSnapshot['name'] ?? 'Admin';
        notifyListeners();
      } else {
        print('Admin document does not exist');
      }
    } catch (e) {
      print('Failed to load admin name: $e');
    }
  }

  Future<void> loadReports() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("payments").get();
      _reportsPayments = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      await FirebaseFirestore.instance
          .collection("expenses")
          .get()
          .then((value) {
        _reportsExpences.addAll(value.docs.map((doc) => doc.data()).toList());
      });
      await FirebaseFirestore.instance
          .collection("attendance")
          .get()
          .then((value) {
        _reportsAttendance.addAll(value.docs.map((doc) => doc.data()).toList());
      });
      notifyListeners();
    } catch (e) {
      print('Failed to load reports: $e');
    }
  }

  Future<void> addExpense(String title, double amount) async {
    try {
      await FirebaseFirestore.instance.collection("expenses").add({
        'title': title,
        'amount': amount,
        'date': Timestamp.now(),
      });
      loadReports(); // Reload reports to include the new expense
    } catch (e) {
      print('Failed to add expense: $e');
    }
  }

  // Update workout
  Future<void> updateWorkout(String workout, String playerId, String entryId,
      Timestamp entrydate) async {
    try {
      // Update the workout field in the attendance collection
      await FirebaseFirestore.instance
          .collection("attendance")
          .doc(entryId)
          .update({'workout': workout});

      print('Workout updated successfully in attendance collection');
    } catch (e) {
      print('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> addtrainingTemplates() async {
    DocumentReference docref =
        await FirebaseFirestore.instance.collection('trainingTemplates').add({
      'trainingName ': '',
      'description ': '',
      'exercises': [],
    });
    String traininId = docref.id;
    await docref.update({
      'traininId': traininId,
    });
  }

  Future<String> addtrainingexercise(
      String name, String instructions, int sets, int reps) async {
    try {
      DocumentReference docref =
          await FirebaseFirestore.instance.collection('exercises').add({
        'name': name,
        'instructions': instructions,
        'sets': sets,
        'reps': reps,
      });
      String exerciseId = docref.id;
      await docref.update({
        'exerciseId': exerciseId,
      });
      return exerciseId; // Return the ID for reference
    } catch (e) {
      print('Failed to add training exercise: $e');
      rethrow;
    }
  }
}
