import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/pages/home_screen/admin_home.dart';
import 'package:psa_academy/pages/home_screen/coach_home.dart';
import 'package:psa_academy/pages/home_screen/player_home.dart';
import 'package:psa_academy/pages/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Authprovider>(context);

    // Show loading indicator while initializing
    if (authProvider.keepSignedIn && authProvider.role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Redirect logic
    if (authProvider.keepSignedIn && authProvider.role != null) {
      switch (authProvider.role!.toLowerCase()) {
        case 'admin':
          return const AdminHome();
        case 'coach':
          return const CoachHome();
        case 'player':
          return const PlayerHome();
        default:
          return const LoginScreen();
      }
    } else {
      return const LoginScreen();
    }
  }
}
