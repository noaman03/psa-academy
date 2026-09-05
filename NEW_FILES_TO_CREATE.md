# New Files to Create After Running Refactor Script

## File 1: core/themes/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:psa_academy/core/constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.errorColor,
        surface: AppColors.surfaceColor,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      
      iconTheme: IconThemeData(
        color: AppColors.primaryColor,
        size: 24,
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.errorColor,
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFF1E1E1E),
      ),
    );
  }
}
```

---

## File 2: core/themes/text_styles.dart

```dart
import 'package:flutter/material.dart';
import 'package:psa_academy/core/constants/colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
  
  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
  
  // Label
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  
  // Error text
  static TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.errorColor,
  );
  
  // Link text
  static TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );
  
  // Card title
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  // Card subtitle
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
}
```

---

## File 3: core/constants/strings.dart

```dart
class AppStrings {
  // App
  static const String appName = 'PSA Academy';
  
  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signInHere = 'Sign in here';
  static const String signUpHere = 'Sign up here';
  
  // Roles
  static const String admin = 'Admin';
  static const String coach = 'Coach';
  static const String player = 'Player';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  
  // Training
  static const String training = 'Training';
  static const String trainingTemplate = 'Training Template';
  static const String trainingTemplates = 'Training Templates';
  static const String addTraining = 'Add Training';
  static const String editTraining = 'Edit Training';
  static const String deleteTraining = 'Delete Training';
  static const String exercise = 'Exercise';
  static const String exercises = 'Exercises';
  static const String addExercise = 'Add Exercise';
  
  // Player
  static const String players = 'Players';
  static const String playerDetails = 'Player Details';
  static const String addPlayer = 'Add Player';
  static const String editPlayer = 'Edit Player';
  
  // Coach
  static const String coaches = 'Coaches';
  static const String coachDetails = 'Coach Details';
  static const String addCoach = 'Add Coach';
  static const String editCoach = 'Edit Coach';
  
  // Attendance
  static const String attendance = 'Attendance';
  static const String markAttendance = 'Mark Attendance';
  static const String present = 'Present';
  static const String absent = 'Absent';
  
  // Report
  static const String report = 'Report';
  static const String reports = 'Reports';
  static const String generateReport = 'Generate Report';
  
  // Messages
  static const String noData = 'No data available';
  static const String noInternet = 'No internet connection';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  
  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Invalid email address';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
}
```

---

## File 4: core/errors/failures.dart

```dart
abstract class Failure {
  final String message;
  
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

---

## File 5: Update main.dart

Add the theme import and use it:

```dart
import 'package:psa_academy/core/themes/app_theme.dart';

// In MyApp build method:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'PSA Academy',
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.light, // or ThemeMode.system
    home: const SplashScreen(),
  );
}
```

---

## Instructions:

1. First, run `refactor_to_clean_arch.bat`
2. Then manually create the folders if they don't exist:
   - `lib/core/themes/`
   - `lib/core/errors/`
3. Copy each code section above into its corresponding file
4. Update imports in main.dart
5. Run `flutter pub get`
6. Test your app

## Quick Import Fix Commands:

If you're using VS Code, use Find and Replace (Ctrl+Shift+H) with these patterns:

1. Replace: `from 'package:psa_academy/pages/` 
   With: `from 'package:psa_academy/presentation/pages/`

2. Replace: `from 'package:psa_academy/widgets/`
   With: `from 'package:psa_academy/presentation/widgets/common/`

3. Replace: `from 'package:psa_academy/service/provider/`
   With: `from 'package:psa_academy/presentation/providers/`

4. Replace: `from 'package:psa_academy/service/firebase/`
   With: `from 'package:psa_academy/data/datasources/remote/`

5. Replace: `from 'package:psa_academy/utils/constants/`
   With: `from 'package:psa_academy/core/constants/`

6. Replace: `from 'package:psa_academy/utils/`
   With: `from 'package:psa_academy/core/utils/`

7. Replace: `from 'package:psa_academy/controller/`
   With: `from 'package:psa_academy/core/utils/`
