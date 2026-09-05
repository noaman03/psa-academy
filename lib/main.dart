import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_environment.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/admin_controller.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/coach_controller.dart';
import 'presentation/controllers/player_controller.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with environment configuration
  await Firebase.initializeApp(
    options: AppEnvironment.firebaseOptions,
  );

  // Connect to local emulators if running in emulator / development mode
  await AppEnvironment.configureEmulatorsIfEnabled();

  // Initialize Clean Architecture GetIt dependencies
  await di.initializeDependencies();

  // Initialize notifications safely
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository: di.sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminController(
            playerRepository: di.sl(),
            coachRepository: di.sl(),
            attendanceRepository: di.sl(),
            financeRepository: di.sl(),
            templateRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CoachController(
            coachRepository: di.sl(),
            attendanceRepository: di.sl(),
            playerRepository: di.sl(),
            templateRepository: di.sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerController(
            playerRepository: di.sl(),
            attendanceRepository: di.sl(),
          ),
        ),
      ],
      child: const PSAAcademyApp(),
    ),
  );
}

class PSAAcademyApp extends StatelessWidget {
  const PSAAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSA Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
