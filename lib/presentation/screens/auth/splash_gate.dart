import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/app_user.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authController = context.read<AuthController>();
    await authController.checkInitialAuth();

    if (!mounted) return;

    if (!authController.isAuthenticated || authController.currentUser == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final role = authController.currentRole;
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
        break;
      case UserRole.coach:
        Navigator.pushReplacementNamed(context, AppRoutes.coachHome);
        break;
      case UserRole.player:
        Navigator.pushReplacementNamed(context, AppRoutes.playerHome);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        break;
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
                  color: Colors.black.withValues(alpha: 0.16),
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
