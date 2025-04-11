import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../data/services/auth_service.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthService _authService = AuthService();

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(LoginLoading());

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      final data = response.data;

      if (data['status'] == 'success') {
        emit(LoginSuccess(userData: data['data']));
      } else {
        emit(LoginError(message: data['message']));
      }
    } catch (e) {
      emit(LoginError(message: "Giriş sırasında hata oluştu."));
    }
  }
}
