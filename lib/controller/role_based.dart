import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psa_academy/pages/home_screen/admin_home.dart';
import 'package:psa_academy/pages/home_screen/coach_home.dart';
import 'package:psa_academy/pages/home_screen/player_home.dart';

Future<String?> getUserRole(String uid) async {
  try {
    // Check if the user is a player
    DocumentSnapshot player =
        await FirebaseFirestore.instance.collection('players').doc(uid).get();
    if (player.exists) return 'player';

    // Check if the user is a coach
    DocumentSnapshot coach =
        await FirebaseFirestore.instance.collection('coaches').doc(uid).get();
    if (coach.exists) return 'coach';

    // Check if the user is an admin
    DocumentSnapshot admin =
        await FirebaseFirestore.instance.collection('admin').doc(uid).get();
    if (admin.exists) return 'admin';

    // If no role is found
    return null;
  } catch (e) {
    print('Error fetching user role: $e');
    return 'error';
  }
}

void navAfterLogin(BuildContext context, String role) {
  if (role == "player") {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const PlayerHome(),
    ));
  } else if (role == "coach") {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const CoachHome(),
    ));
  } else if (role == "admin") {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const AdminHome(),
    ));
  } else {
    print("Invalid role");
  }
}
