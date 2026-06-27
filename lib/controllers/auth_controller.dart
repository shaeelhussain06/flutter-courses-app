import 'package:flutter_app/enums/auth_state.dart';
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/services/session_service.dart';

class AuthController {
  final SessionService _sessionService = SessionService();

  AuthState authState = AuthState.initial;

  Future<void> registerUser(UserModel user) async {
    authState = AuthState.loading;
    await _sessionService.saveRegisteredUser(user);
    authState = AuthState.unauthenticated;
  }

  Future<UserModel?> loginUser({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    authState = AuthState.loading;

    final registeredUser = await _sessionService.getRegisteredUser();

    if (registeredUser == null) {
      authState = AuthState.unauthenticated;
      return null;
    }

    final isValidUser =
        registeredUser.email.toLowerCase() == email.toLowerCase() &&
            registeredUser.password == password;

    if (!isValidUser) {
      authState = AuthState.unauthenticated;
      return null;
    }

    await _sessionService.saveUserSession(registeredUser, rememberMe);
    authState = AuthState.authenticated;

    return registeredUser;
  }

  Future<UserModel?> checkSavedSession() async {
    authState = AuthState.loading;

    final user = await _sessionService.getCurrentSessionUser();

    if (user == null) {
      authState = AuthState.unauthenticated;
      return null;
    }

    authState = AuthState.authenticated;
    return user;
  }

  Future<void> logout() async {
    authState = AuthState.loading;
    await _sessionService.clearSession();
    authState = AuthState.unauthenticated;
  }
}