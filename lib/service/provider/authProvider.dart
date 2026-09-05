import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:psa_academy/service/firebase/firebase_auth.dart';
import 'package:psa_academy/service/firebase/firebase_fstore.dart';
import 'package:psa_academy/controller/role_based.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authprovider with ChangeNotifier {
  User? _user;
  String? _role = '';
  bool _keepSignedIn = false;

  User? get user => _user;
  String? get role => _role;
  bool get keepSignedIn => _keepSignedIn;

  Future<void> initialize() async {
    await loadKeepSignedInPreference();
    if (_keepSignedIn) {
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        _role = await loadRoleFromPrefs();
        if (_role == null) {
          _role = await getUserRole(_user!.uid);
          await saveRoleToPrefs(_role);
        }
      }
    }
    notifyListeners();
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      // Use the authentication service for login
      final auth = authentication();
      _user = await auth.login(email: email, password: password);

      if (_user != null) {
        _role = await getUserRole(_user!.uid);

        // Save the role to preferences
        await saveRoleToPrefs(_role);

        notifyListeners();
      } else {
        throw FirebaseAuthException(
          code: 'unknown-error',
          message: 'Login failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Just rethrow the exception for the UI to handle
      throw e;
    } catch (e) {
      // Convert other errors to FirebaseAuthException for consistent error handling
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  Future<void> saveKeepSignedInPreference(bool keepSignedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepSignedIn', keepSignedIn);
    _keepSignedIn = keepSignedIn;
    notifyListeners();
  }

  Future<void> loadKeepSignedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _keepSignedIn = prefs.getBool('keepSignedIn') ?? false;
    notifyListeners();
  }

  Future<void> saveRoleToPrefs(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role != null) {
      await prefs.setString('userRole', role);
    } else {
      await prefs.remove('userRole');
    }
  }

  Future<String?> loadRoleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    _role = '';
    await saveKeepSignedInPreference(false);
    await saveRoleToPrefs(null);
    notifyListeners();
  }

  //signup
  Future<String?> signup({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      _user = userCredential.user;
      String collectionName;
      if (role == "player") {
        collectionName = "players";
      } else if (role == "coach") {
        collectionName = "coaches";
      } else if (role == "admin") {
        collectionName = "admin";
      } else {
        return ("Invalid role provided");
      }
      await FirebaseFstore().createuser(
          collectionname: collectionName, email: email, name: name, role: role);
      notifyListeners();
    } on FirebaseException catch (e) {
      final errorMessage = (e as dynamic).message ?? e.toString();
      return "Signup failed: $errorMessage";
    } catch (e) {
      return "Signup failed: ${e.toString()}";
    }
    return null;
  }

  Future<String?> signupWithFullProfile({
    required String email,
    required String password,
    required String name,
    required String role,
    required String phone,
    required DateTime dateOfBirth,
    // Optional role-specific data
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // 1. Create the Firebase Auth account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());

      _user = userCredential.user;
      String userId = _user!.uid;

      // 2. Prepare the user data (simplified)
      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'role': role,
      };

      // 3. Add any additional role-specific data
      if (additionalData != null) {
        userData.addAll(additionalData);
      }

      // 4. Save to general users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      // 5. Save to role-specific collection
      String collectionName = '${role}s'; // players, coaches, admins
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userId)
          .set(userData);

      // 6. Set role in provider
      _role = role;
      await saveRoleToPrefs(role);

      notifyListeners();
      return userId;
    } on FirebaseAuthException catch (e) {
      return "Signup failed: ${e.message ?? e.toString()}";
    } catch (e) {
      return "Signup failed: ${e.toString()}";
    }
  }

  // Get saved email from SharedPreferences
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedEmail');
  }

  // Get saved password from SharedPreferences
  Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedPassword');
  }

  // Save user credentials to SharedPreferences
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  // Clear saved credentials from SharedPreferences
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');
  }
}
