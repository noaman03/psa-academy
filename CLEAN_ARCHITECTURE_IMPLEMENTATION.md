# Clean Architecture Migration Guide

## Overview
This project has been restructured to follow Clean Architecture principles, separating concerns into distinct layers: Domain, Data, and Presentation.

## Architecture Structure

### 1. Core Layer (`lib/core/`)
Contains shared utilities, constants, and base classes used across all layers.

#### Constants
- **`lib/core/constants/app_constants.dart`**: Firebase collection names, SharedPreferences keys, responsive breakpoints
- **`lib/core/constants/route_constants.dart`**: Route name constants for type-safe navigation

#### Errors
- **`lib/core/errors/failures.dart`**: Complete Failure hierarchy for functional error handling
  - AuthFailure
  - DatabaseFailure
  - NetworkFailure
  - NotFoundFailure
  - ValidationFailure
  - StorageFailure
  - PermissionDeniedFailure

#### Use Cases
- **`lib/core/usecases/usecase.dart`**: Base UseCase interface for all use cases

#### Dependency Injection
- **`lib/core/di/injection_container.dart`**: GetIt service locator setup
  - Registers all datasources, repositories, and use cases
  - Call `initializeDependencies()` in main.dart before runApp()

### 2. Config Layer (`lib/config/`)
Contains app-wide configuration including theme and routing.

#### Theme
- **`lib/config/theme/color_scheme.dart`**: Complete color palette with role-specific colors
- **`lib/config/theme/text_styles.dart`**: Typography system (display, headline, title, body, label, button, input)
- **`lib/config/theme/button_styles.dart`**: Responsive button styles with size constraints
- **`lib/config/theme/input_decorations.dart`**: Input field decoration styles
- **`lib/config/theme/app_theme.dart`**: Main theme configuration

#### Routes
- **`lib/config/routes/app_router.dart`**: Centralized route generation
  - Use `AppRouter.onGenerateRoute` in MaterialApp
  - Helper methods: `push()`, `pushReplacement()`, `pushAndRemoveUntil()`, `pop()`, `canPop()`

### 3. Domain Layer (`lib/domain/`)
Pure business logic with no framework dependencies.

#### Entities
- **`lib/domain/entities/user_entity.dart`**: User with role (admin/player/coach)
- **`lib/domain/entities/player_entity.dart`**: Player with stats and payments
- **`lib/domain/entities/coach_entity.dart`**: Coach with specialization
- **`lib/domain/entities/attendance_entity.dart`**: Attendance records
- **`lib/domain/entities/payment_entity.dart`**: Payment tracking
- **`lib/domain/entities/expense_entity.dart`**: Expense management

#### Repository Interfaces
- **`lib/domain/repositories/auth_repository.dart`**: Authentication operations
- **`lib/domain/repositories/user_repository.dart`**: User CRUD
- **`lib/domain/repositories/player_repository.dart`**: Player management
- **`lib/domain/repositories/coach_repository.dart`**: Coach management
- **`lib/domain/repositories/attendance_repository.dart`**: Attendance tracking
- **`lib/domain/repositories/payment_repository.dart`**: Payment processing
- **`lib/domain/repositories/expense_repository.dart`**: Expense tracking

#### Use Cases
- **`lib/domain/usecases/auth/`**: SignIn, SignUp, SignOut
- **`lib/domain/usecases/player/`**: GetPlayerById, GetAllPlayers
- **`lib/domain/usecases/attendance/`**: GetAttendanceByDateRange
- **`lib/domain/usecases/payment/`**: GetPaymentsByDateRange
- **`lib/domain/usecases/expense/`**: GetExpensesByDateRange

### 4. Data Layer (`lib/data/`)
Handles data sources and implements repository interfaces.

#### Models
- **`lib/data/models/`**: Firestore models extending entities
  - Includes `fromFirestore()` and `toFirestore()` methods
  - Handles data serialization/deserialization

#### Datasources
- **`lib/data/datasources/firebase_auth_datasource.dart`**: Firebase Auth wrapper
- **`lib/data/datasources/firestore_*_datasource.dart`**: Firestore operations
  - User, Player, Coach, Attendance, Payment, Expense

#### Repository Implementations
- **`lib/data/repositories/*_repository_impl.dart`**: Implement domain repository interfaces
  - Convert models to entities
  - Handle exceptions and convert to Failures
  - Return `Either<Failure, T>` for functional error handling

### 5. Presentation Layer (`lib/presentation/`)
UI components organized by feature.

#### Common Widgets
- **`lib/presentation/widgets/common/custom_button.dart`**: Responsive button with variants
  - Variants: primary, secondary, outline, text, success, error, warning
  - Sizes: small, medium, large
  - Props: isLoading, isFullWidth, icon, customColor
  
- **`lib/presentation/widgets/common/custom_text_field.dart`**: Text input with variants
  - Variants: standard, rounded, underlined, filled
  - Built-in password visibility toggle
  - Validation support
  
- **`lib/presentation/widgets/common/loading_indicator.dart`**: Loading states
  - LoadingIndicator: Customizable circular progress
  - LoadingOverlay: Full screen loading
  
- **`lib/presentation/widgets/common/error_message.dart`**: Error displays
  - ErrorMessage: Full error display with retry
  - InlineErrorMessage: Compact error for forms
  
- **`lib/presentation/widgets/common/custom_card.dart`**: Card variants
  - CustomCard: Base card with styling
  - InfoCard: Icon + title + subtitle
  - StatsCard: Metric display with trends
  
- **`lib/presentation/widgets/common/empty_state.dart`**: Empty states
  - EmptyState: Generic empty state
  - NoDataFound: No data available
  - NoResultsFound: Search results empty
  - NoItemsYet: First-time user state
  - ConnectionError: Network error state

## Migration Steps

### Step 1: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Config
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'config/routes/route_constants.dart';

// Dependency Injection
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize dependencies
  await di.initializeDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSA Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: RouteConstants.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
```

### Step 2: Create Providers (if using Provider for state management)

Create provider wrappers for repositories:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
// ... import other repositories

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => di.sl()),
        Provider<UserRepository>(create: (_) => di.sl()),
        Provider<PlayerRepository>(create: (_) => di.sl()),
        Provider<CoachRepository>(create: (_) => di.sl()),
        Provider<AttendanceRepository>(create: (_) => di.sl()),
        Provider<PaymentRepository>(create: (_) => di.sl()),
        Provider<ExpenseRepository>(create: (_) => di.sl()),
      ],
      child: MaterialApp(
        // ... rest of config
      ),
    );
  }
}
```

### Step 3: Update Existing Screens

Convert screens to use repositories via dependency injection:

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get repository from dependency injection
    final authRepository = di.sl<AuthRepository>();
    final signInUseCase = di.sl<SignInUseCase>();
    
    return Scaffold(
      // Use CustomButton instead of raw ElevatedButton
      body: CustomButton(
        text: 'Sign In',
        onPressed: () async {
          // Use use case for business logic
          final result = await signInUseCase(
            SignInParams(email: email, password: password),
          );
          
          // Handle Either<Failure, User>
          result.fold(
            (failure) {
              // Show error
              showDialog(
                context: context,
                builder: (_) => ErrorMessage(
                  message: failure.message,
                  onRetry: () => Navigator.pop(context),
                ),
              );
            },
            (user) {
              // Navigate to home
              AppRouter.pushReplacementNamed(
                context,
                RouteConstants.authWrapper,
              );
            },
          );
        },
      ),
    );
  }
}
```

### Step 4: Use Common Widgets

Replace custom UI components with common widgets:

**Before:**
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)
```

**After:**
```dart
CustomButton(
  text: 'Submit',
  variant: ButtonVariant.primary,
  size: ButtonSize.medium,
  onPressed: () {},
)
```

**Loading States:**
```dart
// Full screen
LoadingOverlay(
  isLoading: isLoading,
  message: 'Please wait...',
  child: YourContent(),
)

// Inline
if (isLoading) LoadingIndicator(size: LoadingSize.medium)
```

**Empty States:**
```dart
NoDataFound(
  customMessage: 'No players found',
  onRefresh: () => loadPlayers(),
)
```

### Step 5: Handle Errors Properly

Use the `Either<Failure, T>` pattern:

```dart
Future<void> loadPlayers() async {
  final result = await getAllPlayersUseCase(NoParams());
  
  result.fold(
    (failure) {
      // Handle different failure types
      if (failure is NetworkFailure) {
        showError('Network error. Please check connection.');
      } else if (failure is DatabaseFailure) {
        showError('Database error: ${failure.message}');
      }
    },
    (players) {
      setState(() {
        this.players = players;
      });
    },
  );
}
```

## Best Practices

### 1. Dependency Injection
- Always use `di.sl<T>()` to get dependencies
- Never instantiate repositories or use cases directly
- Register new dependencies in `injection_container.dart`

### 2. Error Handling
- Always use `Either<Failure, T>` return types
- Convert exceptions to specific Failure types
- Display user-friendly error messages using ErrorMessage widget

### 3. Navigation
- Use RouteConstants for route names
- Use AppRouter helper methods for navigation
- Pass complex data via constructor parameters, not route arguments

### 4. Theming
- Use AppColors for all colors
- Use AppTextStyles for all text
- Use CustomButton and CustomTextField for consistency
- Never hardcode colors or styles

### 5. State Management
- Keep business logic in use cases
- Use repositories for data access only
- Consider Provider, Bloc, or Riverpod for complex state

### 6. Testing
- Mock repositories in tests (they implement interfaces)
- Test use cases independently
- Test UI with mock dependencies

## Common Patterns

### Repository Usage
```dart
final repository = di.sl<PlayerRepository>();
final result = await repository.getPlayerById(playerId);
```

### Use Case Usage
```dart
final useCase = di.sl<GetPlayerByIdUseCase>();
final result = await useCase(GetPlayerByIdParams(playerId));
```

### Stream Handling
```dart
final repository = di.sl<AttendanceRepository>();
final stream = repository.watchAttendance();

StreamBuilder<List<AttendanceEntity>>(
  stream: stream,
  builder: (context, snapshot) {
    if (snapshot.hasError) return ErrorMessage(message: snapshot.error.toString());
    if (!snapshot.hasData) return LoadingIndicator();
    
    final attendances = snapshot.data!;
    if (attendances.isEmpty) return NoDataFound();
    
    return ListView.builder(/* ... */);
  },
)
```

### Form Validation
```dart
CustomTextField(
  labelText: 'Email',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  },
)
```

## Next Steps

1. ✅ Core infrastructure complete
2. ✅ Theme system complete
3. ✅ Routing system complete
4. ✅ Domain layer complete
5. ✅ Data layer complete
6. ✅ Common widgets complete
7. ✅ Dependency injection complete
8. ⏳ **Next: Migrate existing screens to use new architecture**
9. ⏳ Create feature-specific providers/BLoCs
10. ⏳ Update existing widgets to use common components
11. ⏳ Add unit tests for use cases and repositories
12. ⏳ Add widget tests for common widgets

## File Organization

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── usecases/
│   └── di/
├── config/
│   ├── theme/
│   └── routes/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── pages/          # Feature screens
    └── widgets/
        ├── common/     # Reusable widgets
        └── specific/   # Feature-specific widgets
```

## Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Example](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Dartz Package Documentation](https://pub.dev/packages/dartz)
- [GetIt Documentation](https://pub.dev/packages/get_it)
