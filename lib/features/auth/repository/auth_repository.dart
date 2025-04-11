import '../../../data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _authService.login(
      username: username,
      password: password,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> signup({
    required String fullname,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _authService.signup(
      fullname: fullname,
      username: username,
      email: email,
      password: password,
    );
    return response.data;
  }
}
