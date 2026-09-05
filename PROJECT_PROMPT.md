# PSA Academy Project Prompt

Use this prompt when handing this project to another AI assistant, developer, or reviewer.

```text
You are working on PSA Academy, a Flutter Web + Firebase fitness academy management system.
The project is located at C:\AMIT flutter\psa_academy.

Goal of the app:
Build and maintain a web-based management platform for a fitness/sports academy. The system supports admins, coaches, and players. It handles login/signup, role-based dashboards, player and coach management, QR attendance, workout/training templates, payments, expenses, report exports, file uploads, push notifications, and player progress/history.

Current upload/deployment context:
- Firebase Hosting is configured in firebase.json.
- Hosting public directory is build/web.
- Run flutter build web --release before upload/deploy.
- The latest release build succeeded and refreshed build/web.
- web/index.html and web/manifest.json are the source web shell files used by the build.
- build/web is generated output; do not manually edit it unless doing a one-off emergency patch.
- public/ and (public)/ contain old default Firebase Hosting starter pages and are not the active hosting target.
- functions/ exists but is currently empty.

Tech stack:
- Flutter SDK with Dart 3.5+ constraint in pubspec.yaml.
- Flutter Web target.
- Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Messaging.
- Provider for active app state.
- SharedPreferences for keep-signed-in, saved email/password, and role persistence.
- GetIt dependency injection for the newer clean architecture layer.
- Dartz Either for repository/use-case error handling in the clean architecture layer.
- Equatable for domain entities/failures.
- QR and barcode packages: qr_flutter, pretty_qr_code, mobile_scanner, simple_barcode_scanner, qr_code_scanner, qr_bar_code_scanner_dialog, flutter_web_qrcode_scanner.
- PDF export uses package:pdf and dart:html for web downloads.
- File upload uses file_picker and Firebase Storage.
- Charts dependency: fl_chart.
- Local auth dependency: local_auth.

High-level architecture:
The repo is in a hybrid state:
- Legacy active app screens live mostly under lib/pages, lib/pages/home_screen, lib/widgets, lib/service/provider, and lib/service/firebase.
- A newer clean architecture layer exists under lib/core, lib/config, lib/domain, lib/data, and lib/presentation/widgets/common.
- main.dart initializes Firebase manually with FirebaseOptions, initializes GetIt dependencies, requests push notification permission, then runs a MultiProvider app with Authprovider, PlayerProvider, CoachProvider, and AdminProvider.
- MaterialApp uses AppTheme.lightTheme, AppTheme.darkTheme, AppRouter.onGenerateRoute, initialRoute RouteConstants.splash, and home SplashScreen for compatibility.

Important startup flow:
1. main.dart calls WidgetsFlutterBinding.ensureInitialized().
2. Firebase.initializeApp uses project psa-academy-65088.
3. di.initializeDependencies() registers FirebaseAuth, FirebaseFirestore, datasources, repositories, and use cases.
4. Authprovider.initialize() loads keepSignedIn state and saved role if applicable.
5. PushNotification requests permission and listens for foreground messages.
6. MultiProvider creates Authprovider, PlayerProvider, CoachProvider, and AdminProvider.
7. MyApp builds MaterialApp with theme and router.
8. SplashScreen waits about 2 seconds, then sends users to AuthWrapper if keepSignedIn and role exist, otherwise LoginScreen.
9. AuthWrapper returns AdminHome, CoachHome, PlayerHome, or LoginScreen based on Authprovider.role.

Routes:
- / maps to SplashScreen.
- /login maps to LoginScreen.
- /signup maps to SignupScreen.
- /auth-wrapper maps to AuthWrapper.
- /admin-home maps to AdminHome.
- /player-details requires arguments { playerId } and opens PlayerDetails.
- /coach-details requires arguments { coachId } and opens CoachDetails.
- /coach-home maps to CoachHome.
- /training-templates maps to TrainingTemplatesPage.
- /training-templates-clone requires attendanceId, playerId, date, currentWorkout and opens TrainingTemplatesClonePage.

Current UI/design system:
- The UI was modernized with a teal/coral/ink palette:
  - Primary teal: #00A6A6
  - Primary dark: #006D6F
  - Secondary coral: #FF7A45
  - Background: #F6F8FB
  - Text ink: #101828
- Shared theme files:
  - lib/config/theme/color_scheme.dart
  - lib/config/theme/text_styles.dart
  - lib/config/theme/button_styles.dart
  - lib/config/theme/input_decorations.dart
  - lib/config/theme/app_theme.dart
- Legacy constants were also aligned:
  - lib/utils/constants/colors.dart
  - lib/utils/constants/app_constants.dart
- SplashScreen now has a branded gradient and card loader.
- LoginScreen now has a responsive desktop marketing panel, modern login card, feature pills, and cleaned auth UI.
- AdminHome, CoachHome, and PlayerHome shells now use the updated palette.
- Dashboard cards and balance cards use stronger readable gradients and lower elevation.
- web/index.html title, description, viewport, theme color, and invalid default Firebase script were cleaned.
- web/manifest.json now uses PSA Academy branding.

Main screens:
- SplashScreen:
  Shows PSA logo, branded gradient, progress indicator, then routes based on persisted auth.
- LoginScreen:
  Handles Firebase Auth login through Authprovider. Supports remember-me credential storage, optional biometric login, validation, snackbars, and role-based post-login navigation.
- SignupScreen:
  Three-step account creation flow:
  1. Basic info: name, email, password, phone, date of birth.
  2. Account type: Player, Coach, Admin.
  3. Role details:
     - Player: level, category, age group, membership/payment info.
     - Coach: specialization, years of experience, qualifications, availability.
     - Admin: confirmation notice.
  Calls Authprovider.signupWithFullProfile and writes to users plus role-specific collection.
- AdminHome:
  Four bottom tabs: Dashboard, Finance, Attendance, Settings.
  Loads admin name, report data, player count, coach count, expense categories.
  Dashboard shows current balance, attendance count, active players, active coaches, and quick actions.
  Finance filters payments/expenses by date range, exports PDF, adds expenses.
  Attendance filters attendance by date range, exports PDF, can update workout through TrainingTemplatesClonePage.
  Settings links to training templates, user management/signup, expense categories, and logout.
- CoachHome:
  Four bottom tabs: Check-In, Attendance, Recovery, History.
  Loads current coach name from coaches collection.
  Coach QR scanning toggles coach attendance/work session when the scanned token matches the hardcoded academy QR value.
  Player QR scanning stores scanned player id.
  Attendance marks player session and creates attendance/payment records.
  Payment tab assigns payment amount to scanned player.
  Recovery tab charges selected recovery type if coach is allowed.
  History lists today's attendance and shows workout details.
- PlayerHome:
  Loads current player data: name, balance, sessionsPaid, sessionsAttended, history.
  Shows current balance and QR code.
  Shows training progress cards.
  Lists payment/workout history from attendance collection and can show workout details.
- PlayerDetails:
  Admin/detail screen for player info, file upload, QR/profile details, balance/history management, and status actions.
- CoachDetails:
  Admin/detail screen for coach info, work sessions, total hours/salary calculations, and allowed status toggling.
- TrainingTemplatesPage:
  CRUD-like Firestore screen for training templates and exercises. Supports template editing, exercise adding/editing, instructions overlays, and template details.
- TrainingTemplatesClonePage:
  Similar to TrainingTemplatesPage but used to assign a template or temporary customized workout to an attendance record.

State providers:
- Authprovider:
  Tracks Firebase user, role, keepSignedIn.
  Methods: initialize, login, save/load keepSignedIn, save/load role, logout, signup, signupWithFullProfile, getSavedEmail, getSavedPassword, saveCredentials, clearSavedCredentials.
  Uses SharedPreferences keys savedEmail, savedPassword, keepSignedIn, userRole.
- AdminProvider:
  Tracks adminName, reportsAttendance, reportsPayments, reportsExpences.
  Methods: loadAdminName, loadReports, addExpense, updateWorkout, addtrainingTemplates, addtrainingexercise.
- CoachProvider:
  Tracks coachname, balance, reportsAttendance, sessionPrice.
  Methods: loadcoachName, getPlayerBalance, markFitnessAttendance, assignPayment, markRecoveryAttendance, handleCoachAttendance, loadReports.
- PlayerProvider:
  Tracks player name, balance, sessionsPaid, sessionsAttended, history.
  Methods: loadPlayerName, loadPlayerData, attendSession, updatePlayerData.

Firebase/firestore collections used:
- users
- players
- coaches
- admin
- admins
- payments
- expenses
- expences
- attendance
- settings
- trainingTemplates
- exercises
- coachWorkSessions
- sessions
- coachattendace
- notifications

Important collection caveats:
- There is inconsistency between admin and admins.
  - legacy role lookup checks collection admin.
  - core constants define adminsCollection = admins.
  - signupWithFullProfile writes role-specific collection using '${role}s', so admin becomes admins.
  - Older signup/createuser writes admin for admin users.
  This should be standardized before major auth changes.
- There is inconsistency between expenses and expences.
  - Most report code reads expenses.
  - Some dialog/provider naming uses Expences/reportExpences and add_expense_dialog appears to write expences in at least one path.
  Standardize to expenses if fixing finance data.
- CoachProvider.markFitnessAttendance writes type: recovery for a fitness attendance record. Verify intended value.
- Some records use paymentID and some use paymentId. Standardize before building reports around this.
- Some date fields are Firestore Timestamp and some legacy methods store ISO strings. Be careful when querying/sorting.

Clean architecture layer:
- lib/core/constants/app_constants.dart:
  App name/version, collection names, SharedPreferences keys, breakpoints, default session price, player levels/categories/age groups, coach specializations, default expense categories.
- lib/core/constants/route_constants.dart:
  Route names.
- lib/core/errors/failures.dart:
  Failure hierarchy: Server, Cache, Network, Auth, Unauthorized, InvalidCredentials, UserNotFound, EmailAlreadyExists, WeakPassword, Database, NotFound, AlreadyExists, PermissionDenied, Validation, InvalidInput, Storage, FileUpload, FileDownload, Unknown.
- lib/core/usecases/usecase.dart:
  Base UseCase<Type, Params> and NoParams.
- lib/core/di/injection_container.dart:
  Registers FirebaseAuth/FirebaseFirestore, all datasources, all repository implementations, and use cases.
- lib/domain/entities:
  UserEntity, PlayerEntity, CoachEntity, AttendanceEntity, PaymentEntity, ExpenseEntity with Equatable, copyWith, and helper getters.
- lib/domain/repositories:
  Interfaces for auth, users, players, coaches, attendance, payments, expenses.
- lib/domain/usecases:
  SignIn, SignUp, SignOut, GetPlayerById, GetAllPlayers, GetAttendanceByDateRange, GetPaymentsByDateRange, GetExpensesByDateRange.
- lib/data/models:
  Firestore models extend entities and provide fromFirestore, toFirestore, fromEntity, toEntity.
- lib/data/datasources:
  FirebaseAuthDataSource and Firestore datasources for user/player/coach/attendance/payment/expense.
- lib/data/repositories:
  Implement interfaces, convert datasource errors into Failures, return Either.
- lib/presentation/widgets/common:
  CustomButton, CustomTextField, CustomCard/InfoCard/StatsCard, LoadingIndicator/LoadingOverlay, ErrorMessage/InlineErrorMessage, EmptyState variants.

Legacy service layer:
- lib/service/firebase/firebase_auth.dart:
  authentication class wraps FirebaseAuth login/signup with validation and user-friendly FirebaseAuthException mapping.
- lib/service/firebase/firebase_fstore.dart:
  FirebaseFstore creates role documents, marks attendance, creates sessions, creates coach attendance, assigns payments, adds expenses, sends notifications.
- lib/service/firebase/firebase_message.dart:
  PushNotification requests notification permission, logs FCM token, listens to foreground messages.
- lib/service/firebase/firebase_storage.dart:
  storagemethod uploads player files to Firebase Storage and stores metadata under players/{playerId}. Also contains FileUploadWidget.
- lib/utils/shared_preferences_helper.dart:
  Simple keepSignedIn helpers.
- lib/utils/export_pdf.dart:
  Creates a PDF table and downloads it in the browser with dart:html.

Reusable and feature widgets:
- lib/widgets:
  responsive_container.dart, constrained_button.dart, error_popup.dart, qr_popup.dart, qr_scanner.dart, report_listBuilder.dart, addExercisePage.dart.
- lib/pages/home_screen/admin_widgets:
  Admin dashboard and finance/attendance widgets: metric cards, action cards, balance card, add expense dialog, date range picker, export buttons, finance item/date header, attendance item, empty state, settings card, search results, expense categories dialog.
- lib/pages/home_screen/coach_widgets:
  Section titles, scan cards, attendance/payment/recovery cards, scanned/no-player states, history items, empty history state.
- lib/pages/home_screen/player_widgets:
  Balance/QR card, progress section/stat cards, workout history item, empty workout history.

Assets:
- assets/images/main_large.png and main_large (2).png: main logo variants.
- assets/images/mainNOBG.png, mainNOBGF.png, mainNOBGFW.png: no-background logo variants used in login/app bars/splash.
- assets/images/loginBg (1).jpg: login background image.
- assets/images/communication.png and psaicon.png: supporting image/icon assets.
- assets/icons/main_large.svg and facebook-svgrepo-com.svg.
- pubspec.yaml includes assets/images/ and assets/icons/.

Web files:
- web/index.html:
  Flutter web shell with PSA Academy metadata, background color, jsQR CDN, and main.dart.js.
- web/manifest.json:
  PWA metadata with PSA Academy name/theme/background/icons.
- web/firebase-messaging-sw.js:
  Firebase Messaging service worker with Firebase JS compat imports and project config.
- web/icons and favicon/webicon files:
  PWA/browser icons.

Generated or stale files:
- build/:
  Generated Flutter output and hosting target. Latest build succeeded.
- .dart_tool/, .firebase/:
  Tool/cache directories.
- public/ and (public)/:
  Default Firebase starter pages, not active in firebase.json.
- test/widget_test.dart:
  Still the default Flutter counter test and does not match PSA Academy. Update or remove before relying on tests.
- README.md and clean architecture markdown files:
  Useful, but some contain encoding artifacts and may describe migration aspirations as complete even though active screens still use legacy providers/direct Firebase calls.

Recent UI changes applied:
- Synced modern design tokens in both config and legacy constants.
- Updated Material theme for modern app bars, cards, inputs, buttons, chips, dialogs, snackbars, navigation, and FAB.
- Reworked splash screen with gradient/logo/loading card.
- Reworked login screen with responsive layout, desktop marketing panel, modern card, feature pills, and updated copy.
- Updated admin/coach/player dashboard shells to use the new palette.
- Updated metric/action/balance/scan/attendance/progress cards to use lower elevation, 8px radii, borders, and readable gradients.
- Updated web title/description/theme/manifest branding.
- Removed invalid inline Firebase JS initialization from web/index.html because Firebase is initialized in Dart main.dart.

Validation already run:
- dart format was run on edited Dart files.
- flutter analyze ran and reported info/lint warnings only, mostly pre-existing project-wide style/deprecation warnings. It exits nonzero because there are 319 issues of lint/info severity.
- flutter build web --release succeeded and produced build/web.

Known analyzer/lint situation:
- Many file names are not lower_case_with_underscores.
- Many print calls remain.
- Many BuildContext-across-async-gap warnings remain.
- Several withOpacity deprecation warnings remain due newer Flutter linting.
- Some clean architecture docs contain old import examples and encoding artifacts.
- The app compiles despite these warnings.

Recommended next technical cleanup:
1. Standardize Firestore collection names: admin vs admins, expenses vs expences, paymentID vs paymentId.
2. Replace default widget_test.dart with real smoke/widget tests for Splash/Login/AuthWrapper.
3. Remove or archive stale public/ and (public)/ starter pages if they confuse deployment.
4. Move active screens gradually from direct Firebase calls/providers into the clean architecture repositories/use cases.
5. Replace SharedPreferences password storage with a safer auth persistence strategy.
6. Fix use_build_context_synchronously cases in auth, details, and dashboard flows.
7. Remove print statements or replace with a logging abstraction.
8. Add Firestore security rules and indexes documentation if missing outside this repo.
9. Add a clear deployment README: flutter build web --release, firebase deploy --only hosting.

When editing this project:
- Preserve Firebase project config unless explicitly asked to change it.
- Avoid changing business logic while doing UI-only updates.
- Prefer existing Provider patterns for active screens unless the task is specifically to continue the clean architecture migration.
- Keep design tokens in both lib/config/theme and lib/utils/constants aligned because the app uses both.
- Use assets declared in pubspec.yaml; do not reference undeclared assets.
- Run dart format and flutter build web --release after UI changes.
- Be careful with generated build/web: it is overwritten by flutter build web.
```

