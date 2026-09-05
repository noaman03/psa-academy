import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:psa_academy/service/firebase/firebase_fstore.dart';

class authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Improved login function with better error handling and input validation
  Future<User?> login({required String email, required String password}) async {
    // Input validation
    if (email.isEmpty || !email.contains('@')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is not valid.',
      );
    }

    if (password.isEmpty) {
      throw FirebaseAuthException(
        code: 'empty-password',
        message: 'Password cannot be empty.',
      );
    }

    try {
      // Normalize inputs
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedPassword = password.trim();

      // Add timeout to prevent indefinite waiting
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: normalizedEmail,
            password: normalizedPassword,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw FirebaseAuthException(
              code: 'timeout',
              message:
                  'Login timed out. Please check your internet connection.',
            ),
          );

      // Check if email is verified if needed
      // Uncomment this if you require email verification
      /*
      if (!userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }
      */

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors with user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this email.',
          );
        case 'wrong-password':
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'Incorrect password. Please try again.',
          );
        case 'user-disabled':
          throw FirebaseAuthException(
            code: 'user-disabled',
            message: 'This account has been disabled. Please contact support.',
          );
        case 'too-many-requests':
          throw FirebaseAuthException(
            code: 'too-many-requests',
            message: 'Too many failed login attempts. Please try again later.',
          );
        case 'invalid-credential':
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Wrong email or password.',
          );
        default:
          throw FirebaseAuthException(
            code: e.code,
            message: e.message ?? 'An authentication error occurred.',
          );
      }
    } catch (e) {
      // Non-Firebase errors (like network issues)
      if (e is TimeoutException) {
        throw FirebaseAuthException(
          code: 'timeout',
          message: 'Login timed out. Please check your internet connection.',
        );
      }

      // Log the error for debugging (consider using a proper logging system)
      print('Login error: $e');

      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  //register function
  Future<void> signup({
    required String email,
    required String name,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      if (email.isNotEmpty &&
          role.isNotEmpty &&
          password.isNotEmpty &&
          name.isNotEmpty &&
          password == confirmPassword) {
        await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        String collectionName;
        if (role == "player") {
          collectionName = "players";
        } else if (role == "coach") {
          collectionName = "coaches";
        } else if (role == "admin") {
          collectionName = "admin";
        } else {
          throw Exception("Invalid role provided");
        }
        await FirebaseFstore().createuser(
            collectionname: collectionName,
            email: email,
            name: name,
            role: role);
      }
      print("User registered successfully!");
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }
}
