import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  void updateUser(UserModel newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  final DatabaseService _db;

  UserProvider(this._db);
  UserModel? _currentUser;
  UserModel? get user => _currentUser;

  loadUser(String uid) async {
    final userData = await _db.loadUser(uid);
    if (userData != null) {
      _currentUser = UserModel.fromMap(userData);
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners(); // This is crucial to inform listeners of the change.
  }
}
