import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../models/user_role.dart';

/// Local data source for user authentication data
class AuthLocalDataSource {
  static const String _userBoxName = 'user_box';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  Box? _userBox;

  /// Initialize the user box
  Future<void> init() async {
    _userBox = await Hive.openBox(_userBoxName);
  }

  /// Save current user to local storage
  Future<void> saveUser(User user) async {
    await _ensureBoxOpen();
    await _userBox!.put(_userKey, user.toJson());
  }

  /// Get current user from local storage
  User? getUser() {
    try {
      if (_userBox == null || !_userBox!.isOpen) {
        // Try to open box synchronously if not already open
        _userBox = Hive.box(_userBoxName);
      }
      
      final userJson = _userBox!.get(_userKey) as Map<dynamic, dynamic>?;
      if (userJson == null) return null;

      return User.fromJson(Map<String, dynamic>.from(userJson));
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _ensureBoxOpen();
    await _userBox!.put(_tokenKey, token);
  }

  /// Get authentication token
  String? getToken() {
    try {
      if (_userBox == null || !_userBox!.isOpen) {
        // Try to open box synchronously if not already open
        _userBox = Hive.box(_userBoxName);
      }
      return _userBox!.get(_tokenKey) as String?;
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _ensureBoxOpen();
    await _userBox!.delete(_userKey);
    await _userBox!.delete(_tokenKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return getUser() != null && getToken() != null;
  }

  Future<void> _ensureBoxOpen() async {
    if (_userBox == null || !_userBox!.isOpen) {
      _userBox = await Hive.openBox(_userBoxName);
    }
  }
}
