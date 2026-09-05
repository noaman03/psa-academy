# Clean Architecture Refactoring Guide

## Overview
This guide will help you refactor your PSA Academy Flutter project into Clean Architecture.

## Step 1: Run the Refactoring Script

Execute the batch file to create folders and move files:
```batch
refactor_to_clean_arch.bat
```

## Step 2: New Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── colors.dart
│   │   └── strings.dart
│   ├── themes/
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/
│   │   ├── export_pdf.dart
│   │   ├── shared_preferences_helper.dart
│   │   ├── authWrapper.dart
│   │   └── role_based.dart
│   └── errors/
│       └── failures.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── player_model.dart
│   │   ├── coach_model.dart
│   │   └── training_model.dart
│   ├── datasources/
│   │   └── remote/
│   │       ├── firebase_auth.dart
│   │       ├── firebase_fstore.dart
│   │       ├── firebase_message.dart
│   │       └── firebase_storage.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── player_repository_impl.dart
│       └── coach_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── player.dart
│   │   ├── coach.dart
│   │   └── training.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── player_repository.dart
│   │   └── coach_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── signup_usecase.dart
│       │   └── logout_usecase.dart
│       └── training/
│           ├── add_template_usecase.dart
│           └── get_templates_usecase.dart
│
└── presentation/
    ├── pages/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   ├── signup_screen.dart
    │   │   └── splash_screen.dart
    │   ├── admin/
    │   │   └── admin_home.dart
    │   ├── coach/
    │   │   ├── coach_home.dart
    │   │   ├── coach_details.dart
    │   │   ├── trainingTemplates.dart
    │   │   └── trainingTemplatesClone.dart
    │   └── player/
    │       ├── player_home.dart
    │       └── player_details.dart
    ├── widgets/
    │   ├── common/
    │   │   ├── constrained_button.dart
    │   │   ├── qr_scanner.dart
    │   │   ├── report_listBuilder.dart
    │   │   └── responsive_container.dart
    │   └── dialogs/
    │       ├── error_popup.dart
    │       ├── qr_popup.dart
    │       └── addExercisePage.dart
    └── providers/
        ├── adminProvider.dart
        ├── authProvider.dart
        ├── coachProvider.dart
        └── playerProvider.dart

├── main.dart
```

## Step 3: Create Theme Files

After running the script, create these new files:

### 1. `core/themes/app_theme.dart`
Contains the complete theme configuration for your app (light/dark themes)

### 2. `core/themes/text_styles.dart`
Contains reusable text styles

### 3. `core/constants/strings.dart`
Contains all string constants used in the app

### 4. `core/errors/failures.dart`
Contains error handling classes

## Step 4: Create Domain Layer

### Create Entities (domain/entities/)
Pure Dart classes representing business objects

### Create Repository Interfaces (domain/repositories/)
Abstract classes defining contracts for data operations

### Create Use Cases (domain/usecases/)
Single responsibility classes for business logic

## Step 5: Create Data Layer

### Create Models (data/models/)
Data transfer objects that extend entities

### Create Repository Implementations (data/repositories/)
Concrete implementations of repository interfaces

## Step 6: Update Imports

After moving files, you'll need to update all imports. Run:
```bash
dart fix --dry-run
dart fix --apply
```

Or manually update imports to match the new structure:
- Old: `import 'package:psa_academy/pages/login_screen.dart';`
- New: `import 'package:psa_academy/presentation/pages/auth/login_screen.dart';`

## Step 7: Update main.dart

Update your main.dart to use the new theme:

```dart
import 'package:psa_academy/core/themes/app_theme.dart';

class MyApp extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // ... rest of your code
    );
  }
}
```

## Benefits of This Structure

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Easy to unit test business logic independently
3. **Maintainability**: Clear organization makes code easier to maintain
4. **Scalability**: Easy to add new features without affecting existing code
5. **Dependency Rule**: Dependencies point inward (presentation → domain ← data)

## Next Steps

1. Run `refactor_to_clean_arch.bat`
2. Create theme files manually in `core/themes/`
3. Update imports across all files
4. Test the app to ensure everything works
5. Gradually refactor providers to use usecases
6. Create repository interfaces and implementations

## Common Import Patterns

- Constants: `import 'package:psa_academy/core/constants/app_constants.dart';`
- Colors: `import 'package:psa_academy/core/constants/colors.dart';`
- Theme: `import 'package:psa_academy/core/themes/app_theme.dart';`
- Widgets: `import 'package:psa_academy/presentation/widgets/common/constrained_button.dart';`
- Pages: `import 'package:psa_academy/presentation/pages/auth/login_screen.dart';`
- Providers: `import 'package:psa_academy/presentation/providers/authProvider.dart';`
- Services: `import 'package:psa_academy/data/datasources/remote/firebase_auth.dart';`

## Troubleshooting

If you encounter import errors:
1. Use your IDE's "Find and Replace" feature
2. Replace `'package:psa_academy/pages/` with `'package:psa_academy/presentation/pages/`
3. Replace `'package:psa_academy/widgets/` with `'package:psa_academy/presentation/widgets/common/`
4. Replace `'package:psa_academy/service/provider/` with `'package:psa_academy/presentation/providers/`
5. Replace `'package:psa_academy/service/firebase/` with `'package:psa_academy/data/datasources/remote/`
6. Replace `'package:psa_academy/utils/constants/` with `'package:psa_academy/core/constants/`
