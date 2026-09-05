import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/repositories/training_template_repository.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/repositories/coach_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../data/repositories/training_template_repository_impl.dart';

final sl = GetIt.instance;

/// Initialize all PSA Academy V2 dependencies
Future<void> initializeDependencies() async {
  // External dependencies - Firebase instances
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }
  if (!sl.isRegistered<FirebaseStorage>()) {
    sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  }

  // Canonical Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(auth: sl(), firestore: sl()),
    );
  }
  if (!sl.isRegistered<PlayerRepository>()) {
    sl.registerLazySingleton<PlayerRepository>(
      () => PlayerRepositoryImpl(firestore: sl(), storage: sl()),
    );
  }
  if (!sl.isRegistered<CoachRepository>()) {
    sl.registerLazySingleton<CoachRepository>(
      () => CoachRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<AttendanceRepository>()) {
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<FinanceRepository>()) {
    sl.registerLazySingleton<FinanceRepository>(
      () => FinanceRepositoryImpl(sl()),
    );
  }
  if (!sl.isRegistered<TrainingTemplateRepository>()) {
    sl.registerLazySingleton<TrainingTemplateRepository>(
      () => TrainingTemplateRepositoryImpl(sl()),
    );
  }
}
