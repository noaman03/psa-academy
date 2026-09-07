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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  hintText: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                if (dialogMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    dialogMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: isSuccess ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background image with brand gradient overlay
            Positioned.fill(
              child: Image.asset(
                'assets/images/loginBg (1).jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF071C1D).withValues(alpha: 0.88),
                      const Color(0xFF006D6F).withValues(alpha: 0.82),
                      const Color(0xFFFF7A45).withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Form(
                          key: _formKey,
                          child: Flex(
                            direction: size.width >= 920
                                ? Axis.horizontal
                                : Axis.vertical,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (size.width >= 920) ...[
                                Expanded(child: _buildMarketingPanel()),
                                const SizedBox(width: 48),
                              ],
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 430),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildHeader(),
                                    const SizedBox(height: 28),
                                    _buildLoginCard(isLoading),
                                    const SizedBox(height: 18),
                                    TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Version display at the bottom
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Text(
                'v2.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Hero(
          tag: 'app_logo',
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Image(
              image: AssetImage('assets/images/mainNOBGF.png'),
              width: 72,
              height: 72,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Welcome text
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage players, coaches, sessions, and reports.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketingPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Text(
            'PSA Academy Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'One clean system for training, attendance, payments, and progress.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Admin, coach, and player tools stay connected through Firebase so academy operations feel fast and organized.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeaturePill(icon: Icons.qr_code_scanner, label: 'QR check-ins'),
            _FeaturePill(icon: Icons.payments_outlined, label: 'Payments'),
            _FeaturePill(icon: Icons.fitness_center, label: 'Workouts'),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Email Field
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF006D6F),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF006D6F), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Password Field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF006D6F),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF006D6F), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D6F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
