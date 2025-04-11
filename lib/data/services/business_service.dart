import 'package:dio/dio.dart';
import 'dio_client.dart';

class BusinessService {
  final Dio _dio = DioClient().dio;

  Future<Response> addBusiness(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    final response = await _dio.post("business/add_business.php", data: formData);
    return response;
  }
}
