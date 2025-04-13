import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/dio_client.dart';

class SearchRepository {
  final Dio _dio = DioClient().dio;

  Future<List<BusinessModel>> searchBusinesses({required String query}) async {
    final response = await _dio.get("business/get_business.php", queryParameters: {
      "query": query,
    });

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message']);
    }
  }

  Future<List<BusinessModel>> fetchBusinessesByRadius({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  }) async {
    final response = await _dio.get(
      "business/get_business_by_radius.php",
      queryParameters: {
        "lat": latitude,
        "lon": longitude,
        "radius": radiusKm,
        if (category != null) "category": category,
      },
    );

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception(response.data['message']);
    }
  }
}
