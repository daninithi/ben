import 'dart:developer';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/others/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends BaseViewmodel {
  final AuthService _auth;

  LoginViewModel(this._auth);

  String _email = '';
  String _password = '';

  setEmail(String value) {
    _email = value;
    notifyListeners();
    log("Email: $_email"); // Log the email for debugging
  } 

  setPassword(String value) {
    _password = value;
    notifyListeners();
    log("Password: $_password"); // Log the password for debugging
  }

  login() async{
    setstate(ViewState.loading);
    try {
     await _auth.login(_email, _password);
     setstate(ViewState.idle);
    } on FirebaseAuthException catch (e) {
      setstate(ViewState.idle);
      rethrow;
    } catch (e) {
      log(e.toString());
      setstate(ViewState.idle);
      rethrow;
    }
  }
}