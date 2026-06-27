import 'dart:convert';

import 'package:flutter_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _registeredUserKey = 'registered_user';
  static const String _currentUserKey = 'current_user';
  static const String _rememberMeKey = 'remember_me';

  Future<void> saveRegisteredUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredUserKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_registeredUserKey);

    if (userData == null) {
      return null;
    }

    final decodedData = jsonDecode(userData);
    return UserModel.fromJson(decodedData);
  }

  Future<void> saveUserSession(UserModel user, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_rememberMeKey, rememberMe);

    if (rememberMe) {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  Future<UserModel?> getCurrentSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

    if (!rememberMe) {
      return null;
    }

    final userData = prefs.getString(_currentUserKey);

    if (userData == null) {
      return null;
    }

    final decodedData = jsonDecode(userData);
    return UserModel.fromJson(decodedData);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_rememberMeKey, false);
  }
}