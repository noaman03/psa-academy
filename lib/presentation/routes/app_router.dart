import 'package:flutter/material.dart';
import '../screens/auth/splash_gate.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/coach/coach_screen.dart';
import '../screens/coach/coach_scan_screen.dart';
import '../screens/player/player_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashGate(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpScreen(),
        );

      case AppRoutes.adminHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminScreen(),
        );

      case AppRoutes.coachHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CoachScreen(),
        );

      case AppRoutes.coachScan:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CoachScanScreen(),
        );

      case AppRoutes.playerHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlayerScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashGate(),
        );
    }
  }
}
