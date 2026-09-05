import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, AppUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure('Login failed. User session not found.'));
      }

      // Resolve role
      final roleEither = await getUserRole(user.uid);
      final role = roleEither.fold((l) => UserRole.unknown, (r) => r);

      final appUser = AppUser(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? '',
        role: role,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

      return Right(appUser);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(AuthFailure('Unexpected login error: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpPlayer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    String? level,
    String? category,
    String? ageGroup,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        return const Left(AuthFailure('Failed to create user account.'));
      }

      final now = DateTime.now();

      // Atomically write user document & player document in a batch
      final batch = _firestore.batch();

      final userDoc = _firestore.collection('users').doc(user.uid);
      batch.set(userDoc, {
        'id': user.uid,
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'role': 'player',
        'phone': phone.trim(),
        'isActive': true,
        'createdAt': Timestamp.fromDate(now),
      });

      final playerDoc = _firestore.collection('players').doc(user.uid);
      batch.set(playerDoc, {
        'userId': user.uid,
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'level': level ?? 'Beginner',
        'category': category ?? 'Junior',
        'ageGroup': ageGroup ?? 'Under 12',
        'balance': 0.0,
        'sessionsPaid': 0,
        'sessionsAttended': 0,
        'isAllowedPlayer': true,
        'isActive': true,
        'joinDate': Timestamp.fromDate(now),
        'history': [],
      });

      await batch.commit();

      final appUser = AppUser(
        id: user.uid,
        email: email,
        name: name,
        role: UserRole.player,
        phoneNumber: phone,
        createdAt: now,
      );

      return Right(appUser);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(AuthFailure('Account creation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to sign out: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Right(null);

      // Try reading users/{uid}
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return Right(UserModel.fromFirestore(doc));
      }

      // Fallback role search
      final roleEither = await getUserRole(user.uid);
      final role = roleEither.fold((l) => UserRole.unknown, (r) => r);

      return Right(
        AppUser(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          role: role,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserRole>> getUserRole(String uid) async {
    try {
      // 1. Check users collection
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final roleStr = userDoc.data()!['role'] as String?;
        final role = AppUser.roleFromString(roleStr);
        if (role != UserRole.unknown) return Right(role);
      }

      // 2. Legacy fallback: check players collection
      final playerDoc = await _firestore.collection('players').doc(uid).get();
      if (playerDoc.exists) return const Right(UserRole.player);

      // 3. Legacy fallback: check coaches collection
      final coachDoc = await _firestore.collection('coaches').doc(uid).get();
      if (coachDoc.exists) return const Right(UserRole.coach);

      // 4. Legacy fallback: check admin or admins collection
      final adminDoc = await _firestore.collection('admin').doc(uid).get();
      if (adminDoc.exists) return const Right(UserRole.admin);

      final adminsDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminsDoc.exists) return const Right(UserRole.admin);

      return const Right(UserRole.unknown);
    } catch (e) {
      return Left(FirestoreFailure('Failed to determine user role: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthException(e));
    } catch (e) {
      return Left(AuthFailure('Failed to send reset email: $e'));
    }
  }

  @override
  Stream<String?> watchAuthState() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  Failure _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundFailure('No user found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsFailure('Incorrect email or password.');
      case 'email-already-in-use':
        return const EmailAlreadyExistsFailure(
            'An account with this email already exists.');
      case 'weak-password':
        return const WeakPasswordFailure(
            'The password is too weak. Please use at least 6 characters.');
      case 'invalid-email':
        return const ValidationFailure('The email address is not valid.');
      case 'too-many-requests':
        return const AuthFailure(
            'Too many failed attempts. Please try again later.');
      default:
        return AuthFailure(e.message ?? 'Authentication error occurred.');
    }
  }
}
