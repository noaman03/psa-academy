import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/app_user.dart';
import '../controllers/auth_controller.dart';
import '../widgets/common/app_button.dart';
import 'app_routes.dart';

class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // 1. Unauthenticated check
    if (!authController.isAuthenticated || authController.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Authentication Required',
                  style: AppTypography.headlineMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Please sign in to access this PSA Academy workspace.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Go to Sign In',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Role permission check
    final currentRole = authController.currentRole;
    if (!allowedRoles.contains(currentRole)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.warning,
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Access Restricted',
                  style: AppTypography.headlineMd,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your account (${currentRole.name.toUpperCase()}) does not have permission to view this workspace.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Return to Authorized Workspace',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.splash,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Authorized
    return child;
  }
}
