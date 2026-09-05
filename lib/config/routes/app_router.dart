import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pages/splash_screen.dart';
import '../../pages/login_screen.dart';
import '../../pages/signup_screen.dart';
import '../../controller/authWrapper.dart';
import '../../pages/home_screen/admin_home.dart';
import '../../pages/player_details.dart';
import '../../pages/coach_details.dart';
import '../../pages/home_screen/coach_home.dart';
import '../../pages/trainingTemplates.dart';
import '../../pages/trainingTemplatesClone.dart';
import '../../core/constants/route_constants.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case RouteConstants.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteConstants.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case RouteConstants.authWrapper:
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
          settings: settings,
        );

      case RouteConstants.adminHome:
        return MaterialPageRoute(
          builder: (_) => const AdminHome(),
          settings: settings,
        );

      case RouteConstants.playerDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('playerId')) {
          return _errorRoute('Player ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => PlayerDetails(playerID: args['playerId'] as String),
          settings: settings,
        );

      case RouteConstants.coachDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('coachId')) {
          return _errorRoute('Coach ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => CoachDetails(coachiD: args['coachId'] as String),
          settings: settings,
        );

      case RouteConstants.coachHome:
        return MaterialPageRoute(
          builder: (_) => const CoachHome(),
          settings: settings,
        );

      case RouteConstants.trainingTemplates:
        return MaterialPageRoute(
          builder: (_) => TrainingTemplatesPage(),
          settings: settings,
        );

      case RouteConstants.trainingTemplatesClone:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('attendanceId') ||
            !args.containsKey('playerId') ||
            !args.containsKey('date') ||
            !args.containsKey('currentWorkout')) {
          return _errorRoute(
              'Missing required parameters for training template clone');
        }
        return MaterialPageRoute(
          builder: (_) => TrainingTemplatesClonePage(
            attendanceId: args['attendanceId'] as String,
            playerId: args['playerId'] as String,
            date: args['date'] as Timestamp,
            currentWorkout: args['currentWorkout'] as String,
          ),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }

  // Navigation helper methods
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
