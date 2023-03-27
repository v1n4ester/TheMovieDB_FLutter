// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_list/domain/api_client/api_client_exception.dart';
import 'package:movie_list/domain/services/auth_service.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  bool _isAuthProgress = false;
  bool get isAuthInProgress => _isAuthProgress;
  bool get canStartAuth => !_isAuthProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isValid(String login, String password) =>
      login.isNotEmpty && password.isNotEmpty;

  Future<String?> _login(String login, String password) async {
    try {
      await _authService.login(login, password);
    } on ApiClientException catch (e) {
      switch (e.type) {
        case ApiClientExceptionType.network:
          return 'Server error. Check the internet connection';
        case ApiClientExceptionType.auth:
          return 'Invalid login or password';
        case ApiClientExceptionType.other:
          return 'Error ocured. Try again';
        default:
          print(e);
      }
    } catch (e) {
      _errorMessage = 'Unknown error, try again';
    }
    return null;
  }

  Future<void> auth(BuildContext context) async {
    final login = loginTextController.text;
    final password = passwordTextController.text;

    if (!_isValid(login, password)) {
      _updateState('Enter the login and password', false);
      notifyListeners();
      return;
    }

    _updateState(null, true);

    _errorMessage = await _login(login, password);

    if (_errorMessage == null) {
      MainNavigation.resetNavigation(context);
    } else {
      _updateState(_errorMessage, false);
    }
  }

  void _updateState(String? errorMessage, bool isAuthProgress) {
    if (_errorMessage == errorMessage && _isAuthProgress == isAuthProgress) {
      return;
    }
    _errorMessage = errorMessage;
    _isAuthProgress = isAuthProgress;
    notifyListeners();
  }
}

// class AuthProvider extends InheritedNotifier{
//   final AuthModel model;
//   const AuthProvider(
//     {
//     Key? key,
//     required this.model,
//     required Widget child
//     }) : super(
//       key: key,
//       notifier: model,
//       child: child
//     );

//   static AuthProvider? watch(BuildContext context){
//     return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
//   }

//   static AuthProvider? read(BuildContext context){
//     final widget= context.getElementForInheritedWidgetOfExactType<AuthProvider>()?.widget;
//     return widget is AuthProvider ? widget : null;
//   }
// }