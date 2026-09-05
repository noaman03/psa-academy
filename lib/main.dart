import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/pages/splash_screen.dart';
import 'package:psa_academy/service/firebase/firebase_message.dart';
import 'package:psa_academy/service/provider/playerProvider.dart';
import 'package:psa_academy/service/provider/adminProvider.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/service/provider/coachProvider.dart';

// Clean Architecture imports
import 'package:psa_academy/config/theme/app_theme.dart';
import 'package:psa_academy/config/routes/app_router.dart';
import 'package:psa_academy/core/constants/route_constants.dart';
import 'package:psa_academy/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBpS5SLEllgLbnghtAT6JEH7UMnQ-Tmjz4",
          storageBucket: "psa-academy-65088.firebasestorage.app",
          appId: "1:353959379596:web:9e2db8c46070672e6f71a9",
          messagingSenderId: "353959379596",
          projectId: "psa-academy-65088"));

  // Initialize Clean Architecture dependencies
  await di.initializeDependencies();

  final authporvider = Authprovider();
  await authporvider.initialize();
  // FirebaseMessaging.instance.subscribeToTopic('admin_notification');
  PushNotification().myRequestPermission();
  PushNotification().showPushNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Authprovider()),
        ChangeNotifierProvider(create: (context) => PlayerProvider()),
        ChangeNotifierProvider(create: (context) => CoachProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PSA Academy',
      // Apply clean architecture theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Use clean architecture routing
      initialRoute: RouteConstants.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Fallback to direct splash screen for backward compatibility
      home: const SplashScreen(),
    );
  }
}
