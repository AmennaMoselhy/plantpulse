import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? _profileImagePath;
  String _email = '';
  String _password = '';

  String? get profileImagePath => _profileImagePath;
  String get email => _email;
  String get password => _password;

  // ✅ حفظ الإيميل والباسورد عند Login أو Register
  void saveUserData({required String email, required String password}) {
    _email = email;
    _password = password;
    notifyListeners();
  }

  // ✅ تحديث الإيميل من Edit Profile
  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  // ✅ تحديث الباسورد من Change Password
  void updatePassword(String newPassword) {
    _password = newPassword;
    notifyListeners();
  }

  // ✅ تحديث صورة البروفايل
  void updateProfileImage(String path) {
    _profileImagePath = path;
    notifyListeners();
  }

  // ✅ مسح كل حاجة عند Logout
  void clearAll() {
    _profileImagePath = null;
    _email = '';
    _password = '';
    notifyListeners();
  }
}

final userState = UserState();