import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  String? _profileImagePath;
  String? _profileImageUrl;
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _token = '';
  String _gender = '';

  String get gender => _gender;
  String get token => _token;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl;
  String get email => _email;
  String get password => _password;
  String get fullName => _fullName;

  Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();

  Future<void> saveUserData({
    required String email,
    required String password,
    String fullName = '',
    String gender = '',
  }) async {
    _email = email;
    _password = password;
    _fullName = fullName;
    _gender = gender;
    final prefs = await _getPrefs();
    _token = prefs.getString('savedToken') ?? _token;
    _profileImagePath =
        prefs.getString('savedImagePath_$email') ?? _profileImagePath;
    await _persistLoginState(email, fullName, password, gender);
    notifyListeners();
  }

  Future<void> _persistLoginState(
    String email,
    String fullName,
    String password,
    String gender,
  ) async {
    final prefs = await _getPrefs();
    await prefs.setString('savedFullName', fullName);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  Future<void> updateFullName(String newName) async {
    _fullName = newName;
    final prefs = await _getPrefs();
    await prefs.setString('savedFullName', newName);
    notifyListeners();
  }

  Future<void> updateEmail(String newEmail) async {
    _email = newEmail;
    final prefs = await _getPrefs();
    await prefs.setString('savedEmail', newEmail);
    notifyListeners();
  }

  Future<void> updateGender(String newGender) async {
    _gender = newGender;
    final prefs = await _getPrefs();
    await prefs.setString('savedGender', newGender);
    notifyListeners();
  }
  Future<void> updatePassword(String newPassword) async {
    _password = newPassword;
    await _persistPassword(newPassword);
    notifyListeners();
  }

  Future<void> _persistPassword(String password) async {
    final prefs = await _getPrefs();
    await prefs.setString('savedPassword', password);
  }

  void updateProfileImage(String path) {
    _profileImagePath = path;
    _persistImagePath(path);
    notifyListeners();
  }

  void updateProfileImageUrl(String url) {
    _profileImageUrl = url;
    _persistImageUrl(url);
    notifyListeners();
  }

  Future<void> _persistImagePath(String path) async {
    final prefs = await _getPrefs();
    await prefs.setString('savedImagePath', path);
    if (_email.isNotEmpty) {
      await prefs.setString('savedImagePath_$_email', path);
    }
  }

  Future<void> _persistImageUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString('savedImageUrl', url);
    if (_email.isNotEmpty) {
      await prefs.setString('savedImageUrl_$_email', url);
    }
  }

  Future<void> loadPersistedData() async {
    final prefs = await _getPrefs();
    _token = prefs.getString('savedToken') ?? '';
    _fullName = prefs.getString('savedFullName') ?? '';
    _email = prefs.getString('savedEmail') ?? '';
    _password = prefs.getString('savedPassword') ?? '';
    _gender = prefs.getString('savedGender') ?? 'male';
    _profileImagePath = _email.isNotEmpty
        ? (prefs.getString('savedImagePath_$_email') ??
              prefs.getString('savedImagePath'))
        : prefs.getString('savedImagePath');
    _profileImageUrl = _email.isNotEmpty
        ? (prefs.getString('savedImageUrl_$_email') ??
        prefs.getString('savedImageUrl'))
        : prefs.getString('savedImageUrl');
  }

  Future<void> clearAll() async {
    final emailToDelete = _email;
    _profileImagePath = null;
    _profileImageUrl = null;
    _token = '';
    _email = '';
    _password = '';
    _gender = '';
    _fullName = '';
    final prefs = await _getPrefs();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('savedToken');
    await prefs.remove('savedEmail');
    await prefs.remove('savedFullName');
    await prefs.remove('savedPassword');
    await prefs.remove('savedGender');
    await prefs.remove('savedImagePath');
    await prefs.remove('savedImageUrl');
    if (emailToDelete.isNotEmpty) {
      await prefs.remove('savedImagePath_$emailToDelete');
      await prefs.remove('savedImageUrl_$emailToDelete');
    }
    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await _getPrefs();
    await prefs.setString('savedToken', token);
    notifyListeners();
  }

}

final userState = UserState();
