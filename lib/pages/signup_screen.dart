import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/provider/authProvider.dart';
import 'package:psa_academy/utils/constants/app_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  // Step tracking
  int _currentStep = 0;
  bool _isLoading = false;
  String _error = '';

  // User type selection
  final List<String> _userTypes = ['Player', 'Coach', 'Admin'];
  String _selectedUserType = 'Player';

  // Common fields for all user types
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _dateOfBirth;

  // Player-specific fields
  String _playerLevel = 'Beginner';
  final List<String> _playerLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional'
  ];

  String _playerCategory = 'Junior';
  final List<String> _playerCategories = ['Junior', 'Senior', 'Elite'];

  String _playerAgeGroup = 'Under 12';
  final List<String> _playerAgeGroups = [
    'Under 8',
    'Under 10',
    'Under 12',
    'Under 14',
    'Under 16',
    'Under 18',
    'Adult'
  ];

  // Coach-specific fields
  final TextEditingController _experienceYearsController =
      TextEditingController();
  final TextEditingController _qualificationsController =
      TextEditingController();

  String _coachSpecialization = 'Technical Coach';
  final List<String> _coachSpecializations = [
    'Technical Coach',
    'Fitness Coach',
    'Goalkeeping Coach',
    'Mental Coach',
    'Head Coach'
  ];

  List<String> _selectedAvailability = [];
  final List<String> _availabilityOptions = [
    'Monday Morning',
    'Monday Afternoon',
    'Monday Evening',
    'Tuesday Morning',
    'Tuesday Afternoon',
    'Tuesday Evening',
    'Wednesday Morning',
    'Wednesday Afternoon',
    'Wednesday Evening',
    'Thursday Morning',
    'Thursday Afternoon',
    'Thursday Evening',
    'Friday Morning',
    'Friday Afternoon',
    'Friday Evening',
    'Saturday Morning',
    'Saturday Afternoon',
    'Saturday Evening',
    'Sunday Morning',
    'Sunday Afternoon',
    'Sunday Evening',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _experienceYearsController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: AppAnimations.short,
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.all(AppSizing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Basic Info'),
                  _buildStepSeparator(0),
                  _buildStepIndicator(1, 'Account Type'),
                  _buildStepSeparator(1),
                  _buildStepIndicator(2, 'Additional Details'),
                ],
              ),
            ),

            // Error message
            if (_error.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSizing.m,
                  vertical: AppSizing.s,
                ),
                padding: const EdgeInsets.all(AppSizing.m),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: AppSizing.s),
                    Expanded(
                      child: Text(
                        _error,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Form steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildBasicInfoStep(),
                  _buildAccountTypeStep(),
                  _buildAdditionalDetailsStep(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            if (_currentStep > 0)
              TextButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: AppAnimations.short,
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkGrey,
                ),
              )
            else
              const SizedBox.shrink(),

            // Next/Submit button
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton(
                    onPressed: () => _handleNextStep(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizing.l,
                        vertical: AppSizing.m,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizing.borderRadiusMedium),
                      ),
                    ),
                    child: Text(
                      _currentStep < 2 ? 'Next' : 'Create Account',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    _currentStep > step ? Icons.check : Icons.circle,
                    color: Colors.white,
                    size: _currentStep > step ? 16 : 12,
                  )
                : Text(
                    (step + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepSeparator(int step) {
    final isActive = _currentStep > step;
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppColors.primary : Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // Step 1: Basic Information
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizing.m),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: 'e.g., +20 1234567890',
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Date of Birth
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: AppInputDecorations.defaultInput.copyWith(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today),
                  hintText: 'Select your date of birth',
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Select your date of birth'
                      : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Account Type
  Widget _buildAccountTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizing.m),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Account Type',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSizing.s),
            const Text(
              'Choose the type of account you want to create',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSizing.l),

            // Account Type Selection Cards
            ...List.generate(_userTypes.length, (index) {
              final userType = _userTypes[index];
              return _buildUserTypeCard(
                userType: userType,
                isSelected: _selectedUserType == userType,
                onTap: () {
                  setState(() {
                    _selectedUserType = userType;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // Step 3: Additional Details based on account type
  Widget _buildAdditionalDetailsStep() {
    switch (_selectedUserType) {
      case 'Player':
        return _buildPlayerDetailsForm();
      case 'Coach':
        return _buildCoachDetailsForm();
      case 'Admin':
        return _buildAdminDetailsForm();
      default:
        return Container();
    }
  }

  Widget _buildPlayerDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizing.m),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Player Details',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSizing.s),
            const Text(
              'Please provide additional information about your playing experience',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSizing.l),

            // Player Level Selection
            const Text(
              'Player Level',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSizing.xs),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _playerLevel,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizing.m),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  items: _playerLevels
                      .map((level) => DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _playerLevel = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizing.m),

            // Player Category
            const Text(
              'Player Category',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSizing.xs),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _playerCategory,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizing.m),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  items: _playerCategories
                      .map((category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _playerCategory = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizing.m),

            // Player Age Group
            const Text(
              'Age Group',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSizing.xs),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _playerAgeGroup,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizing.m),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  items: _playerAgeGroups
                      .map((ageGroup) => DropdownMenuItem<String>(
                            value: ageGroup,
                            child: Text(ageGroup),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _playerAgeGroup = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizing.m),

            // Info card about payment tiers
            Container(
              padding: const EdgeInsets.all(AppSizing.m),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      SizedBox(width: AppSizing.s),
                      Text(
                        'Payment Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizing.s),
                  Text(
                    'Your membership fees will be calculated based on your level and category:',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSizing.s),
                  _buildPaymentTierRow('Beginner - Junior', '\$50/month'),
                  _buildPaymentTierRow('Intermediate - Junior', '\$75/month'),
                  _buildPaymentTierRow('Advanced - Junior', '\$100/month'),
                  _buildPaymentTierRow('Beginner - Senior', '\$75/month'),
                  _buildPaymentTierRow('Intermediate - Senior', '\$100/month'),
                  _buildPaymentTierRow('Advanced - Senior', '\$125/month'),
                  _buildPaymentTierRow('Elite - Any Level', '\$200/month'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachDetailsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizing.m),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coach Details',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSizing.s),
            const Text(
              'Please provide information about your coaching experience',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSizing.l),

            // Coach Specialization
            const Text(
              'Coaching Specialization',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSizing.xs),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _coachSpecialization,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizing.m),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  items: _coachSpecializations
                      .map((specialization) => DropdownMenuItem<String>(
                            value: specialization,
                            child: Text(specialization),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _coachSpecialization = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizing.m),

            // Years of Experience
            TextFormField(
              controller: _experienceYearsController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Years of Experience',
                prefixIcon: const Icon(Icons.timer_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your years of experience';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Qualifications and Certifications
            TextFormField(
              controller: _qualificationsController,
              decoration: AppInputDecorations.defaultInput.copyWith(
                labelText: 'Qualifications & Certifications',
                prefixIcon: const Icon(Icons.school_outlined),
                hintText: 'e.g., UEFA A License, FA Level 2, etc.',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your qualifications';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizing.m),

            // Availability
            const Text(
              'Available Time Slots',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppSizing.xs),
            Container(
              padding: const EdgeInsets.all(AppSizing.m),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppSizing.borderRadiusMedium),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select all time slots when you are available to coach',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: AppSizing.s),
                  ...[
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ].map((day) => _buildDayAvailability(day)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDetailsForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizing.m),
        child: Form(
          key: _formKeys[2],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppColors.primary.withOpacity(0.8),
              ),
              const SizedBox(height: AppSizing.m),
              const Text(
                'Admin Account Setup',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizing.m),
              const Text(
                'You are creating an admin account which will have access to all features of the application.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizing.l),
              Container(
                padding: const EdgeInsets.all(AppSizing.m),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppSizing.borderRadiusMedium),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        SizedBox(width: AppSizing.s),
                        Text(
                          'Important Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizing.s),
                    Text(
                      'Admin accounts should only be created for authorized personnel. All admin actions are logged and monitored.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String userType,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon;
    String description;

    switch (userType) {
      case 'Player':
        icon = Icons.sports_soccer;
        description =
            'Join training sessions, track progress, and manage payments';
        break;
      case 'Coach':
        icon = Icons.sports;
        description =
            'Manage training sessions, player progress, and schedules';
        break;
      case 'Admin':
        icon = Icons.admin_panel_settings;
        description =
            'Full access to manage players, coaches, payments, and settings';
        break;
      default:
        icon = Icons.person;
        description = '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizing.m),
        padding: const EdgeInsets.all(AppSizing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizing.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizing.m),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSizing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: userType,
              groupValue: _selectedUserType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedUserType = value;
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTierRow(String tier, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tier,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayAvailability(String day) {
    return ExpansionTile(
      title: Text(day),
      tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      childrenPadding: const EdgeInsets.only(left: AppSizing.m),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTimeSlotChip(day, 'Morning'),
            const SizedBox(width: AppSizing.xs),
            _buildTimeSlotChip(day, 'Afternoon'),
            const SizedBox(width: AppSizing.xs),
            _buildTimeSlotChip(day, 'Evening'),
          ],
        ),
        const SizedBox(height: AppSizing.xs),
      ],
    );
  }

  Widget _buildTimeSlotChip(String day, String timeSlot) {
    final slotKey = '$day $timeSlot';
    final isSelected = _selectedAvailability.contains(slotKey);

    return FilterChip(
      label: Text(timeSlot),
      selected: isSelected,
      checkmarkColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedAvailability.add(slotKey);
          } else {
            _selectedAvailability.remove(slotKey);
          }
        });
      },
    );
  }

  // Helper Methods
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_formKeys[0].currentState!.validate() && _dateOfBirth != null) {
        _pageController.nextPage(
          duration: AppAnimations.short,
          curve: Curves.easeInOut,
        );
      } else if (_dateOfBirth == null) {
        setState(() {
          _error = 'Please select your date of birth';
        });
      }
    } else if (_currentStep == 1) {
      // Account type selection doesn't need validation
      _pageController.nextPage(
        duration: AppAnimations.short,
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 2) {
      // Final step, validate and submit
      if (_validateFinalStep()) {
        _createAccount();
      }
    }
  }

  bool _validateFinalStep() {
    switch (_selectedUserType) {
      case 'Player':
        // Player validation is handled by dropdown defaults
        return true;
      case 'Coach':
        // Coach validation
        if (_formKeys[2].currentState!.validate() &&
            _selectedAvailability.isNotEmpty) {
          return true;
        } else if (_selectedAvailability.isEmpty) {
          setState(() {
            _error = 'Please select at least one availability time slot';
          });
          return false;
        }
        return false;
      case 'Admin':
        // Admin doesn't need extra validation
        return true;
      default:
        return false;
    }
  }

  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final authProvider = Provider.of<Authprovider>(context, listen: false);

      // Prepare role-specific additional data
      Map<String, dynamic> additionalData = {};

      // Add role-specific data
      switch (_selectedUserType) {
        case 'Player':
          additionalData = {
            'playerLevel': _playerLevel,
            'playerCategory': _playerCategory,
            'playerAgeGroup': _playerAgeGroup,
            'isAllowedPlayer': true,
            'paymentStatus': 'pending',
          };
          break;

        case 'Coach':
          // Validate that experienceYears is not empty
          if (_experienceYearsController.text.isEmpty) {
            setState(() {
              _error = 'Please enter your years of experience';
              _isLoading = false;
            });
            return;
          }

          additionalData = {
            'specialization': _coachSpecialization,
            'experienceYears': int.parse(_experienceYearsController.text),
            'qualifications': _qualificationsController.text,
            'availability': _selectedAvailability,
            'isAllowedCoach': true,
          };
          break;

        case 'Admin':
          // Admin-specific data if needed
          break;
      }

      // Call the simplified signup method
      final result = await authProvider.signupWithFullProfile(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        role: _selectedUserType.toLowerCase(),
        phone: _phoneController.text,
        dateOfBirth: _dateOfBirth!,
        additionalData: additionalData,
      );

      // Handle result
      if (result == null || result.startsWith('Signup failed:')) {
        setState(() {
          _error = result ?? 'Account creation failed. Please try again.';
        });
      } else {
        // Success - show message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Variables not defined in properties above
  bool _isPasswordVisible = false;
}
