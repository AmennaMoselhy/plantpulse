import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  String? _profileImagePath;
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _token = '';

  String _gender = '';

  String get gender => _gender;

  String get token => _token;

  String? get profileImagePath => _profileImagePath;

  String get email => _email;

  String get password => _password;

  String get fullName => _fullName;

  Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();

  void saveUserData({
    required String email,
    required String password,
    String fullName = '',
    String gender = '',
  }) {
    _email = email;
    _password = password;
    _fullName = fullName;
    _gender = gender;
    _persistLoginState(email, fullName, password, gender);
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
    await prefs.setString('savedGender', gender);
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

  Future<void> _persistImagePath(String path) async {
    final prefs = await _getPrefs();
    await prefs.setString('savedImagePath', path);
  }

  Future<void> loadPersistedData() async {
    final prefs = await _getPrefs();
    _token = prefs.getString('savedToken') ?? '';
    _fullName = prefs.getString('savedFullName') ?? '';
    _email = prefs.getString('savedEmail') ?? '';
    _password = prefs.getString('savedPassword') ?? '';
    _gender = prefs.getString('savedGender') ?? 'male';
    _profileImagePath = prefs.getString('savedImagePath');
  }

  Future<void> clearAll() async {
    _profileImagePath = null;
    _token = '';
    _email = '';
    _password = '';
    _gender = '';
    _fullName = '';
    await _clearLoginState();

    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await _getPrefs();
    await prefs.setString('savedToken', token);
    notifyListeners();
  }

  Future<void> _clearLoginState() async {
    final prefs = await _getPrefs();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('savedToken');
    await prefs.remove('savedEmail');
    await prefs.remove('savedFullName');
    await prefs.remove('savedPassword');
    await prefs.remove('savedImagePath');
  }
}

final userState = UserState();
