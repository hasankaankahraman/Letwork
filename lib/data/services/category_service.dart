import 'package:dio/dio.dart';
import 'package:letwork/data/services/dio_client.dart';

class CategoryService {
  final Dio _dio = DioClient().dio;

  /// HomeScreen için → düz liste
  Future<List<String>> fetchFlatCategories() async {
    final response = await _dio.get("business/get_categories.php");
    final data = response.data;

    if (data['status'] == 'success') {
      final List groups = data['data'];
      final List<String> flatList = [];

      for (final group in groups) {
        final items = List<String>.from(group['items'] ?? []);
        flatList.addAll(items);
      }

      return flatList;
    } else {
      throw Exception("Kategoriler alınamadı");
    }
  }

  /// AddBusinessScreen için → gruplu liste
  Future<List<Map<String, dynamic>>> fetchGroupedCategories() async {
    final response = await _dio.get("business/get_categories.php");
    final data = response.data;

    if (data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception("Kategoriler alınamadı");
    }
  }
}
