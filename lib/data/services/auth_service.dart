import 'package:dio/dio.dart';
import 'dio_client.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Response> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/login.php',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> signup({
    required String fullname,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'auth/signup.php',
        data: {
          'fullname': fullname,
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
