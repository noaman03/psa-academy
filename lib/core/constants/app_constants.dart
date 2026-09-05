class AppConstants {
  // App Info
  static const String appName = 'PSA Academy';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String playersCollection = 'players';
  static const String coachesCollection = 'coaches';
  static const String adminsCollection = 'admins';
  static const String paymentsCollection = 'payments';
  static const String expensesCollection = 'expenses';
  static const String attendanceCollection = 'attendance';
  static const String settingsCollection = 'settings';
  static const String trainingTemplatesCollection = 'trainingTemplates';

  // Shared Preferences Keys
  static const String roleKey = 'user_role';
  static const String keepSignedInKey = 'keep_signed_in';
  static const String savedEmailKey = 'saved_email';
  static const String savedPasswordKey = 'saved_password';
  static const String lastViewedKey = 'last_viewed_timestamp';

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 960.0;
  static const double desktopBreakpoint = 1280.0;

  // Session Price
  static const int defaultSessionPrice = 100;

  // Player Levels
  static const List<String> playerLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional'
  ];

  // Player Categories
  static const List<String> playerCategories = ['Junior', 'Senior', 'Elite'];

  // Player Age Groups
  static const List<String> playerAgeGroups = [
    'Under 8',
    'Under 10',
    'Under 12',
    'Under 14',
    'Under 16',
    'Under 18',
    'Adult'
  ];

  // Coach Specializations
  static const List<String> coachSpecializations = [
    'Technical Coach',
    'Fitness Coach',
    'Goalkeeping Coach',
    'Mental Coach',
    'Head Coach'
  ];

  // Default Expense Categories
  static const List<String> defaultExpenseCategories = [
    'Rent',
    'Utilities',
    'Salaries',
    'Equipment',
    'Maintenance',
    'Marketing',
    'Other'
  ];
}
