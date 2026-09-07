import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';
import '../screens/auth/splash_gate.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/coach/coach_screen.dart';
import '../screens/coach/coach_scan_screen.dart';
import '../screens/player/player_screen.dart';
import 'app_routes.dart';
import 'role_guard.dart';

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
        // Public self-registration is disabled; redirect to Login
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.adminHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoleGuard(
            allowedRoles: [UserRole.admin],
            child: AdminScreen(),
          ),
        );

      case AppRoutes.coachHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoleGuard(
            allowedRoles: [UserRole.admin, UserRole.coach],
            child: CoachScreen(),
          ),
        );

      case AppRoutes.coachScan:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoleGuard(
            allowedRoles: [UserRole.admin, UserRole.coach],
            child: CoachScanScreen(),
          ),
        );

      case AppRoutes.playerHome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RoleGuard(
            allowedRoles: [UserRole.admin, UserRole.player],
            child: PlayerScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashGate(),
        );
    }
  }
}
