import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:psa_academy/controller/role_based.dart';
import 'package:local_auth/local_auth.dart';

// Import our constants
import 'package:psa_academy/utils/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String _error = '';
  bool _keepSignedIn = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // Check if biometric authentication is available
    _checkBiometricAvailability();

    // Check if we have saved credentials for auto-fill
    _loadSavedCredentials();
  }

  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = false;
    bool isDeviceSupported = false;

    try {
      // Check both conditions required for biometric authentication
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      isDeviceSupported = await _localAuth.isDeviceSupported();

      // Only set as available if both conditions are met
      if (mounted) {
        setState(() {
          _isBiometricAvailable = canCheckBiometrics && isDeviceSupported;
        });
      }
    } catch (e) {
      print('Error checking biometric availability: $e');
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
        });
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    // Check for saved credentials from the provider
    final authprovider = Provider.of<Authprovider>(context, listen: false);
    final savedEmail = await authprovider.getSavedEmail();

    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _keepSignedIn = true;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_isBiometricAvailable) return;

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final authprovider = Provider.of<Authprovider>(context, listen: false);
        final savedEmail = await authprovider.getSavedEmail();
        final savedPassword = await authprovider.getSavedPassword();

        if (savedEmail != null &&
            savedEmail.isNotEmpty &&
            savedPassword != null &&
            savedPassword.isNotEmpty) {
          setState(() {
            _emailController.text = savedEmail;
            _passwordController.text = savedPassword;
          });

          // Proceed with login
          await _login(authprovider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No saved credentials found for biometric login'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Added feedback for when user cancels the biometric authentication
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication canceled'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error using biometrics: $e');

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Biometric authentication failed: ${e.toString().split(']').last}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final authprovider = Provider.of<Authprovider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background with brand image and gradient overlay
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/loginBg (1).jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF071C1D).withOpacity(0.88),
                      AppColors.primaryDark.withOpacity(0.82),
                      AppColors.secondary.withOpacity(0.62),
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
                                const SizedBox(width: 40),
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
                                    _buildLoginCard(authprovider),
                                    const SizedBox(height: 18),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/forgot-password');
                                      },
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
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
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
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
                  color: Colors.black.withOpacity(0.22),
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
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 5),
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
            color: Colors.white.withOpacity(0.9),
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
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
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
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Admin, coach, and player tools stay connected through Firebase so academy operations feel fast and organized.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.82),
            fontSize: 17,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _FeaturePill(icon: Icons.qr_code_scanner, label: 'QR check-ins'),
            _FeaturePill(icon: Icons.payments_outlined, label: 'Payments'),
            _FeaturePill(icon: Icons.fitness_center, label: 'Workouts'),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginCard(Authprovider authprovider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Error message
          if (_error.isNotEmpty) _buildErrorMessage(),

          // Email field
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
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
            decoration: AppInputDecorations.defaultInput.copyWith(
              labelText: "Email",
              hintText: "Enter your email",
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizing.l),

          // Password field
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onFieldSubmitted: (_) async {
              if (_formKey.currentState!.validate()) {
                await _login(authprovider);
              }
            },
            decoration: AppInputDecorations.defaultInput.copyWith(
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.mediumGrey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
          ),

          const SizedBox(height: AppSizing.m),

          // Remember me checkbox and biometric option
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _keepSignedIn,
                  onChanged: (value) {
                    setState(() {
                      _keepSignedIn = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSizing.s),
              Text(
                'Keep me signed in',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_isBiometricAvailable)
                IconButton(
                  icon: const Icon(Icons.fingerprint,
                      color: AppColors.primary, size: 28),
                  onPressed: _authenticateWithBiometrics,
                  tooltip: 'Login with biometrics',
                ),
            ],
          ),

          const SizedBox(height: AppSizing.l),

          // Login button with max width constraint
          _isLoading
              ? const CircularProgressIndicator(color: AppColors.primary)
              : ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: double.infinity,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _login(authprovider);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          "Sign in",
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _error,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _login(Authprovider authprovider) async {
    // Form validation is already handled by the form validator

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await authprovider.login(
        context,
        _emailController.text,
        _passwordController.text,
      );

      // Save credentials if keep signed in is selected
      if (_keepSignedIn) {
        await authprovider.saveKeepSignedInPreference(true);
        await authprovider.saveCredentials(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        // Clear saved credentials if not keeping signed in
        await authprovider.clearSavedCredentials();
        await authprovider.saveKeepSignedInPreference(false);
      }

      String? role = authprovider.role;
      if (role != null) {
        navAfterLogin(context, role);
      } else {
        setState(() {
          _error = 'Failed to retrieve user role';
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth exceptions
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invalid email or password. Please try again.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Too many login attempts. Please try again later or reset your password.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 6),
          ),
        );
      } else {
        // Other Firebase Auth errors
        setState(() {
          if (e.code == 'invalid-email') {
            _error = 'Please enter a valid email address.';
          } else if (e.code == 'network-request-failed') {
            _error =
                'Network connection failed. Please check your internet connection.';
          } else if (e.code == 'timeout') {
            _error = 'Connection timed out. Please try again.';
          } else if (e.code == 'user-disabled') {
            _error = 'This account has been disabled. Please contact support.';
          } else {
            _error = e.message ?? 'Login failed. Please try again later.';
          }
        });
      }
    } catch (e) {
      // Handle other exceptions
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
      });
      print('Unexpected login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
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
            ),
          ),
        ],
      ),
    );
  }
}
