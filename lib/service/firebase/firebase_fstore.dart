import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFstore {
  //firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final int sessionprice = 100;

  //create user function
  Future<void> createuser(
      {required String email,
      required String name,
      required String role,
      required collectionname}) async {
    try {
      User? user = _auth.currentUser;
      await _firestore.collection(collectionname).doc(user!.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'role': role,
        'isAllowedPlayer': role == 'player' ? true : null,
        'isAllowed': role == 'coach' ? true : null,
        'working hours': role == 'coach' ? 0 : null,
        'playerData': role == 'player' ? {} : null,
        'balance': role == 'player' ? 0 : null,
        'sessionsPaid': role == 'player' ? 0 : null,
        'sessionsAttended': role == 'player' ? 0 : null,
        'history': role == 'player' ? [] : null,
      });
    } catch (e) {
      print(e);
    }
  }

  //player attendance fo sessions
  Future<void> markPlayerAttendance(String uid) async {
    DocumentReference coachRef = _firestore.collection('coaches').doc(uid);
    DocumentReference playerRef = _firestore.collection('players').doc(uid);
    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(playerRef);
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }
      int sessionsAttended = snapshot.get('sessionsAttended');
      int sessionsPaid = snapshot.get('sessionsPaid');

      transaction.update(playerRef, {
        'sessionsAttended': sessionsAttended + 1,
        'balance': (sessionsPaid - (sessionsAttended + 1)) * sessionprice,
        'history': FieldValue.arrayUnion([
          {"date": DateTime.now().toIso8601String(), "type": "attendance"}
        ])
      });
      await createPlayerSession(
          date: DateTime.now().toIso8601String(),
          coachId: coachRef.id,
          playerId: playerRef.id,
          sessionPrice: sessionprice);
      print("Attendance marked successfully!");
    });
  }

  //create player session
  Future<void> createPlayerSession(
      {required String date,
      required String coachId,
      required String playerId,
      required int sessionPrice}) async {
    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        "date": date,
        "coachId": coachId,
        "players": [playerId],
        "income": sessionPrice,
        "status": "completed"
      });
    } catch (e) {
      print('failed to create session: $e');
    }
  }

  //create coach attendance
  Future<void> createCoachattendace({
    required String date,
    required String coachId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('coachattendace').add(
          {"date": date, "coachId": coachId, "status": "coach_attendance"});
    } catch (e) {
      print('failed to create session: $e');
    }
  }

  //coach attendace
  Future<void> markCoachAttendace() async {
    DocumentReference coachRef =
        _firestore.collection('coaches').doc(_auth.currentUser!.uid);
    await createCoachattendace(
        date: DateTime.now().toIso8601String(), coachId: coachRef.id);
  }

  //assign payment
  Future<void> assignpayment(String uid, int amount) async {
    DocumentReference playerRef = _firestore.collection('players').doc(uid);
    _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(playerRef);
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }
      int sessionsPaid = snapshot.get('sessionsPaid');
      int balance = snapshot.get('balance');

      transaction.update(playerRef, {
        'sessionsPaid': sessionsPaid + (amount / sessionprice),
        'balance': balance + amount,
        'history': FieldValue.arrayUnion([
          {
            "date": DateTime.now().toIso8601String(),
            "type": "payment",
            "amount": amount
          }
        ])
      });
      await createPayment(
          date: DateTime.now().toIso8601String(),
          playerId: playerRef.id,
          amount: amount);
      print("Payment marked successfully!");
    });
  }

  //create payment
  Future<void> createPayment(
      {required String date,
      required String playerId,
      required int amount}) async {
    try {
      await FirebaseFirestore.instance.collection('payments').add({
        "date": date,
        "playerId": playerId,
        "amount": amount,
        "status": "pending"
      });
    } catch (e) {
      print('failed to create payment: $e');
    }
  }

  //add expense
  Future<void> addexpense(int amount, String reason) async {
    try {
      await _firestore.collection('expenses').add({
        "amount": amount,
        "reason": reason,
        "date": DateTime.now().toIso8601String()
      });
    } catch (e) {
      print('failed to add expense: $e');
    }
  }

  //Send Notification
  Future<void> sendNotification(String message) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add({"message": message, "date": DateTime.now().toIso8601String()});

    print("Notification sent!");
  }
}
