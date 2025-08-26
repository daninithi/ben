// chat_list_viewmodel.dart

import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user.dart';
import 'package:chat_app/core/others/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

class ChatListViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final UserModel currentUser;

  ChatListViewmodel(this._db, this.currentUser);

  List<UserModel> _chatUsers = [];
  List<UserModel> get chatUsers => _chatUsers;

  List<UserModel> _filteredUsers = [];
  List<UserModel> get filteredUsers => _filteredUsers;


  // This method will add users to the list
  fetchUserById(String userId) async {
    if (_chatUsers.any((user) => user.uid == userId)) {
      log("User with ID $userId is already in the list.");
      return;
    }

    try {
      setstate(ViewState.loading);
      
      final userData = await _db.loadUser(userId);
      if (userData != null) {
        final newUser = UserModel.fromMap(userData);
        _chatUsers.add(newUser); // Add the new user to the list
        _filteredUsers = _chatUsers; // Update filtered users to include all chat users
        log("Added user with ID: $userId to the chat list. Total users: ${_chatUsers.length}");
      } else {
        log("No user found with ID: $userId");
      }

      notifyListeners();
      setstate(ViewState.idle);
    } catch (e) {
      setstate(ViewState.idle);
      log(e.toString());
      rethrow;
    }
  }

  search(String value) {
    _filteredUsers =
        _chatUsers.where((e) => e.name!.toLowerCase().contains(value)).toList();
    notifyListeners();
  } 

}

