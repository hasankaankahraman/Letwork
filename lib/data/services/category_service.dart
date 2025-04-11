import 'package:dio/dio.dart';
import 'dio_client.dart';

class CategoryService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await _dio.get("business/get_categories.php");
    final data = response.data;

    if (data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception("Kategoriler alınamadı");
    }
  }
}
