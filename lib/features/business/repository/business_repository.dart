import 'package:dio/dio.dart';
import 'package:letwork/data/services/dio_client.dart';

class BusinessRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> addBusiness(FormData formData) async {
    final response = await _dio.post("business/add_business.php", data: formData);
    return response.data;
  }
}
