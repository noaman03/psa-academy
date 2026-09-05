import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/controller/authWrapper.dart';
import 'package:psa_academy/pages/login_screen.dart';
import 'package:psa_academy/service/provider/authProvider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp(); // Call the method here
  }

  // Define the method
  Future<void> _initializeApp() async {
    final authProvider = Provider.of<Authprovider>(context, listen: false);
    await authProvider.initialize(); // Load saved preferences and auth state

    await Future.delayed(const Duration(seconds: 2)); // Simulate loading time

    // Redirect based on authentication state
    if (authProvider.keepSignedIn && authProvider.role != null) {
      // User is already signed in, navigate to role-based home
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
      ));
    } else {
      // User is not signed in, navigate to login screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF006D6F),
              Color(0xFF00A6A6),
              Color(0xFFFF7A45),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/main_large.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(
                  minHeight: 4,
                  color: Color(0xFF00A6A6),
                  backgroundColor: Color(0xFFE4E7EC),
                ),
                const SizedBox(height: 14),
                Text(
                  'Preparing your academy dashboard',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
