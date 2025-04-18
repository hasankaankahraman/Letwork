import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        final userData = data['data'];

        debugPrint("✅ Giriş başarılı: ${userData.toString()}");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', int.parse(userData['id'].toString()));
        await prefs.setString('username', userData['username']);
        await prefs.setString('email', userData['email']);
        await prefs.setString('fullname', userData['fullname']);

        debugPrint("🧠 SharedPreferences'e kaydedilen userId: ${prefs.getInt('userId')}");

        emit(LoginSuccess(userData: userData));
      } else {
        emit(LoginError(message: data['message']));
      }
    } catch (e) {
      debugPrint("❌ Giriş sırasında exception: $e");
      emit(LoginError(message: "Giriş sırasında hata oluştu."));
    }
  }
}
