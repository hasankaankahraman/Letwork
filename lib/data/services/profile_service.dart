import 'package:dio/dio.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<Map<String, dynamic>> updateProfile({
    required int id,
    required String fullname,
    required String username,
    required String email,
    String? password,
  }) async {
    final response = await _dio.post(
      "https://letwork.hasankaan.com/api/user/update_user.php",
      data: {
        "id": id.toString(),
        "fullname": fullname,
        "username": username,
        "email": email,
        if (password != null && password.isNotEmpty) "password": password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      ),
    );

    return response.data;
  }
}
