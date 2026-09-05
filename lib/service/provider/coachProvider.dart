import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CoachProvider with ChangeNotifier {
  int sessionPrice = 100;
  String _coachname = "";
  String get coachname => _coachname;
  int balance = 0;
  int get getBalance => balance;
  final List<Map<String, dynamic>> _reportsAttendance = [];
  List<Map<String, dynamic>> get reportsAttendace => _reportsAttendance;

  Future<void> loadcoachName(String uid) async {
    try {
      DocumentSnapshot adminSnapshot =
          await FirebaseFirestore.instance.collection('coaches').doc(uid).get();
      if (adminSnapshot.exists) {
        _coachname = adminSnapshot['name'] ?? 'coach';
        notifyListeners();
      } else {
        print('player document does not exist');
      }
    } catch (e) {
      print('Failed to load admin name: $e');
    }
  }

  //load player balance
  Future<void> getPlayerBalance(String playerId) async {
    try {
      DocumentSnapshot playerSnapshot = await FirebaseFirestore.instance
          .collection('players')
          .doc(playerId)
          .get();
      if (playerSnapshot.exists) {
        balance = playerSnapshot['balance'] ?? 0;
        notifyListeners();
      } else {
        print('player document does not exist');
      }
    } catch (e) {
      print('Failed to load player balance: $e');
    }
  }

  // Mark Attendance
  Future<void> markFitnessAttendance(
    int sessionPrice,
    String uid,
    String coachid,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("players").doc(uid).update({
        'balance': FieldValue.increment(-sessionPrice),
        'sessionsPaid': FieldValue.increment(-1),
        'history': FieldValue.arrayUnion([
          {
            "date": Timestamp.now(),
            "type": "fitness attendance",
          }
        ]),
        "sessionsAttended": FieldValue.increment(1)
      });

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection("attendance").add({
        "coachId": coachid,
        "playerId": uid,
        "type": "recovery",
        "date": Timestamp.now(),
      });

      // Retrieve the auto-generated document ID
      String attendanceID = docRef.id;

      // Update the document to include the attendanceID field
      await docRef.update({
        "attendanceID": attendanceID,
      });

      DocumentReference docReef =
          await FirebaseFirestore.instance.collection("payments").add({
        "playerId": uid,
        "amount": sessionPrice,
        "status": balance < sessionPrice ? 'debit' : 'paid',
        "date": Timestamp.now(),
      });

      // Retrieve the auto-generated document ID
      String paymentID = docReef.id;

      // Update the document to include the paymentID field
      await docRef.update({
        'paymentID': paymentID,
      });
      notifyListeners();
    } catch (e) {
      print('Failed to mark attendance: $e');
    }
  }

  // Assign Payments
  Future<void> assignPayment(String uid, int amount) async {
    try {
      await FirebaseFirestore.instance.collection("players").doc(uid).update({
        "balance": FieldValue.increment(amount),
        "sessionsPaid": FieldValue.increment((amount / sessionPrice).floor())
      });

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection("payments").add({
        "playerId": uid,
        "amount": amount,
        "status": "pending",
        "date": Timestamp.now(),
      });

      // Retrieve the auto-generated document ID
      String paymentID = docRef.id;

      // Update the document to include the paymentID field
      await docRef.update({
        'paymentID': paymentID,
      });
      notifyListeners();
    } catch (e) {
      print('Failed to assign payment: $e');
    }
  }

  // recovery attendance
  Future<void> markRecoveryAttendance(
      String playerId, String coachId, double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection("players")
          .doc(playerId)
          .update({
        'balance': FieldValue.increment(-amount),
        'sessionsPaid': FieldValue.increment(-1),
        'history': FieldValue.arrayUnion([
          {"date": Timestamp.now(), "type": "recovery attendance"}
        ]),
        "sessionsAttended": FieldValue.increment(1)
      });

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection("attendance").add({
        "coachId": coachId,
        "playerId": playerId,
        "type": "recovery",
        "date": Timestamp.now(),
      });

      // Retrieve the auto-generated document ID
      String attendanceID = docRef.id;

      // Update the document to include the attendanceID field
      await docRef.update({
        "attendanceID": attendanceID,
      });

      String status = balance < amount ? 'debit' : 'paid';

      // Add a new document to the "payments" collection without specifying a document ID
      DocumentReference doocRef =
          await FirebaseFirestore.instance.collection("payments").add({
        "playerId": playerId,
        "amount": amount,
        "status": status,
        "date": Timestamp.now(),
      });

      // Retrieve the auto-generated document ID
      String paymentID = doocRef.id;
      await docRef.update({
        "paymentId": paymentID,
      });

      notifyListeners();
    } catch (e) {
      print('Failed to mark attendance: $e');
    }
  }

  Future<void> handleCoachAttendance(String coachid, double hourlyRate) async {
    try {
      // Check if there is an active session for the coach
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('coachWorkSessions')
          .where('coachId', isEqualTo: coachid)
          .where('checkOut', isEqualTo: null)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // No active session, create a new check-in
        await FirebaseFirestore.instance.collection('coachWorkSessions').add({
          'coachId': coachid,
          'checkIn': Timestamp.now(),
          'checkOut': null,
          'date': Timestamp.now()
        });
      } else {
        // Active session found, perform check-out
        var doc = snapshot.docs.first;
        Timestamp checkIn = doc['checkIn'];
        Timestamp checkOut = Timestamp.now();
        Duration duration = checkOut.toDate().difference(checkIn.toDate());
        double hoursWorked = duration.inMinutes / 60.0;
        double salary = hoursWorked * hourlyRate;

        // Update the session with check-out time and calculated salary
        await FirebaseFirestore.instance
            .collection('coachWorkSessions')
            .doc(doc.id)
            .update({
          'checkOut': checkOut,
          'hoursWorked': hoursWorked,
          'calculatedSalary': salary,
        });

        // Increment the total worked hours for the coach
        DocumentSnapshot coachSnapshot = await FirebaseFirestore.instance
            .collection('coaches')
            .doc(coachid)
            .get();
        double totalWorkedHours =
            (coachSnapshot['totalWorkedHours'] ?? 0) + hoursWorked;

        await FirebaseFirestore.instance
            .collection('coaches')
            .doc(coachid)
            .update({
          'totalWorkedHours': totalWorkedHours,
        });
      }
    } catch (e) {
      print('Failed to handle coach attendance: $e');
    }
  }

  Future<void> loadReports() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("attendance")
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      _reportsAttendance.clear();
      _reportsAttendance.addAll(snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList());
      notifyListeners();
    } catch (e) {
      print('Failed to load reports: $e');
    }
  }
}
