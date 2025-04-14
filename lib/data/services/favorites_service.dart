import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/dio_client.dart';

class FavoritesService {
  final Dio _dio = DioClient().dio;

  Future<bool> isFavorite(String userId, String businessId) async {
    final response = await _dio.get("favorite/favorite_handler.php", queryParameters: {
      "action": "check",
      "user_id": userId,
      "business_id": businessId,
    });

    if (response.data['status'] == 'success') {
      return response.data['data']['is_favorite'];
    } else {
      throw Exception("Favori durumu alınamadı");
    }
  }

  Future<void> addToFavorites(String userId, String businessId) async {
    await _dio.post("favorite/favorite_handler.php?action=add", data: {
      "user_id": userId,
      "business_id": businessId,
    });
  }

  Future<void> removeFromFavorites(String userId, String businessId) async {
    await _dio.post("favorite/favorite_handler.php?action=remove", data: {
      "user_id": userId,
      "business_id": businessId,
    });
  }

  Future<List<BusinessModel>> fetchUserFavorites(String userId) async {
    final response = await _dio.get("favorite/get_user_favorites.php", queryParameters: {
      "user_id": userId,
    });

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception("Favori işletmeler alınamadı.");
    }
  }
}
