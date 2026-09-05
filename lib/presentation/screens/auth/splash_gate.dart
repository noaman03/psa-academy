import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
      backgroundColor: AppColors.secondary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_soccer,
                  color: AppColors.textWhite,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'PSA ACADEMY',
              style: AppTypography.displaySm.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Performance Sports Academy',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
