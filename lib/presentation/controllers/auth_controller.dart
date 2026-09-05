import 'package:flutter/material.dart';
import '../../core/state/view_state.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  ViewState<AppUser> _state = const ViewState.initial();
  ViewState<AppUser> get state => _state;

  AppUser? get currentUser => _state.data;
  UserRole get currentRole => _state.data?.role ?? UserRole.unknown;
  bool get isAuthenticated => _state.data != null;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<void> checkInitialAuth() async {
    _state = const ViewState.loading();
    notifyListeners();

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        _state = const ViewState.initial();
        notifyListeners();
      },
      (user) {
        if (user != null) {
          _state = ViewState.success(user);
        } else {
          _state = const ViewState.initial();
        }
        notifyListeners();
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    _state = const ViewState.loading();
    notifyListeners();

    final result = await _authRepository.signInWithEmailAndPassword(email, password);
    return result.fold(
      (failure) {
        _state = ViewState.failure(failure.message);
        notifyListeners();
        return false;
      },
      (user) {
        _state = ViewState.success(user);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signUpPlayer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    String? level,
    String? category,
    String? ageGroup,
  }) async {
    _state = const ViewState.loading();
    notifyListeners();

    final result = await _authRepository.signUpPlayer(
      email: email,
      password: password,
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      level: level,
      category: category,
      ageGroup: ageGroup,
    );

    return result.fold(
      (failure) {
        _state = ViewState.failure(failure.message);
        notifyListeners();
        return false;
      },
      (user) {
        _state = ViewState.success(user);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    final result = await _authRepository.resetPassword(email);
    return result.fold((l) => false, (r) => true);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _state = const ViewState.initial();
    notifyListeners();
  }
}
