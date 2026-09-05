import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Data sources
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/datasources/firestore_player_datasource.dart';
import '../../data/datasources/firestore_coach_datasource.dart';
import '../../data/datasources/firestore_attendance_datasource.dart';
import '../../data/datasources/firestore_payment_datasource.dart';
import '../../data/datasources/firestore_expense_datasource.dart';

// Repositories
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/expense_repository.dart';

// Use cases
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/player/get_player_by_id_usecase.dart';
import '../../domain/usecases/player/get_all_players_usecase.dart';
import '../../domain/usecases/attendance/get_attendance_by_date_range_usecase.dart';
import '../../domain/usecases/payment/get_payments_by_date_range_usecase.dart';
import '../../domain/usecases/expense/get_expenses_by_date_range_usecase.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
/// Call this function in main.dart before running the app
Future<void> initializeDependencies() async {
  // External dependencies - Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data sources
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(sl()),
  );
  sl.registerLazySingleton<FirestoreUserDataSource>(
    () => FirestoreUserDataSource(sl()),
  );
  sl.registerLazySingleton<FirestorePlayerDataSource>(
    () => FirestorePlayerDataSource(sl()),
  );
  sl.registerLazySingleton<FirestoreCoachDataSource>(
    () => FirestoreCoachDataSource(sl()),
  );
  sl.registerLazySingleton<FirestoreAttendanceDataSource>(
    () => FirestoreAttendanceDataSource(sl()),
  );
  sl.registerLazySingleton<FirestorePaymentDataSource>(
    () => FirestorePaymentDataSource(sl()),
  );
  sl.registerLazySingleton<FirestoreExpenseDataSource>(
    () => FirestoreExpenseDataSource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  // Use cases - Authentication
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Use cases - Player
  sl.registerLazySingleton(() => GetPlayerByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetAllPlayersUseCase(sl()));

  // Use cases - Attendance
  sl.registerLazySingleton(() => GetAttendanceByDateRangeUseCase(sl()));

  // Use cases - Payment
  sl.registerLazySingleton(() => GetPaymentsByDateRangeUseCase(sl()));

  // Use cases - Expense
  sl.registerLazySingleton(() => GetExpensesByDateRangeUseCase(sl()));
}
