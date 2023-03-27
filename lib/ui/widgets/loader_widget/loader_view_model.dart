// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_list/domain/services/auth_service.dart';
import 'package:movie_list/ui/navigation/main_navigation.dart';

class LoaderViewModel {
  final BuildContext context;
  final _authService = AuthService();

  LoaderViewModel(
    this.context,
  ) {
    asyncInit();
  }

  Future<void> asyncInit() async {
    await checkAuth();
  }

  Future<void> checkAuth() async {
    final isAuth = await _authService.isAuth();
    final nextScreen = isAuth ? MainNavigationRoutesNames.mainScreen : MainNavigationRoutesNames.auth;
    Navigator.of(context).pushReplacementNamed(nextScreen);
  }
}
