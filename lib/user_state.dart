import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  String? _profileImagePath;

  String? get profileImagePath => _profileImagePath;

  void updateProfileImage(String path) {
    _profileImagePath = path;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImagePath = null;
    notifyListeners();
  }
}

// instance واحدة بتتشارك في كل الأب
final userState = UserState();
