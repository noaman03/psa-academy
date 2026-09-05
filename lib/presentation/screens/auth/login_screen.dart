import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/app_user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);
    final authController = context.read<AuthController>();

    final success = await authController.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
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
          setState(() {
            _errorMessage = 'User account has no valid role assigned.';
          });
          break;
      }
    } else {
      setState(() {
        _errorMessage = authController.state.errorMessage ??
            'Invalid email or password. Please try again.';
      });
    }
  }

  void _showForgotPasswordDialog() {
    final emailResetController =
        TextEditingController(text: _emailController.text.trim());
    bool isSubmitting = false;
    String? dialogMessage;
    bool isSuccess = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Reset Password',
              style: AppTypography.headlineSm.copyWith(fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email address and we will send you a password reset link.',
                  style: AppTypography.bodyMd,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: emailResetController,
                  labelText: 'Email Address',
                  hintText: 'player@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                if (dialogMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dialogMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: isSuccess ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              AppButton(
                text: 'Send Reset Link',
                size: AppButtonSize.small,
                isLoading: isSubmitting,
                onPressed: () async {
                  final email = emailResetController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    setDialogState(() {
                      dialogMessage = 'Please enter a valid email address.';
                      isSuccess = false;
                    });
                    return;
                  }

                  setDialogState(() => isSubmitting = true);
                  final ok =
                      await context.read<AuthController>().resetPassword(email);
                  setDialogState(() {
                    isSubmitting = false;
                    if (ok) {
                      isSuccess = true;
                      dialogMessage = 'Reset email sent! Please check your inbox.';
                    } else {
                      isSuccess = false;
                      dialogMessage =
                          'Could not send reset email. Verify your address.';
                    }
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLoading = authController.state.isLoading;
    final size = MediaQuery.of(context).size.width;
    final isDesktop = size >= AppSpacing.tabletBreakpoint;

    final content = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Branding
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.lgBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_soccer,
                  color: AppColors.textWhite,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Welcome to PSA Academy',
            textAlign: TextAlign.center,
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign in to access your training dashboard',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Error Message Banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: AppRadius.smBorderRadius,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Email Field
          AppTextField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          AppTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: '••••••••',
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter your password';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sign In Button
          AppButton(
            text: 'Sign In',
            size: AppButtonSize.large,
            isLoading: isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.signup);
                },
                child: Text(
                  'Register as Player',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: isDesktop
                ? Center(
                    child: Container(
                      width: 440,
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.xlBorderRadius,
                        boxShadow: AppShadows.cardShadow,
                        border: Border.all(color: AppColors.outline, width: 1),
                      ),
                      child: content,
                    ),
                  )
                : content,
          ),
        ),
      ),
    );
  }
}
