import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/dio_client.dart';

class BusinessService {
  final Dio _dio = DioClient().dio;

  // Fetch a specific business detail
  Future<BusinessDetailModel> fetchBusinessDetail(String id) async {
    final response = await _dio.get("business/get_business_detail.php", queryParameters: {
      "business_id": id,
    });

    if (response.data['status'] == 'success') {
      return BusinessDetailModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message']);
    }
  }

  // Fetch all businesses
  Future<List<BusinessModel>> fetchAllBusinesses() async {
    final response = await _dio.get("business/get_business.php");

    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => BusinessModel.fromJson(e)).toList();
    } else {
      throw Exception("İşletmeler alınamadı");
    }
  }

  // Fetch businesses for a specific user
  Future<List<dynamic>> fetchUserBusinesses(int userId) async {
    final response = await _dio.get("business/get_user_businesses.php", queryParameters: {
      "user_id": userId,
    });

    if (response.data['status'] == 'success') {
      return response.data['data'];
    } else {
      throw Exception("Kullanıcıya ait işletmeler alınamadı");
    }
  }

  // Update business details
  Future<Map<String, dynamic>> updateBusiness(FormData formData) async {
    final response = await _dio.post("business/update_business.php", data: formData);
    return response.data;
  }

  // Delete a business
  Future<Map<String, dynamic>> deleteBusiness(int businessId, int userId) async {
    final response = await _dio.post("business/delete_business.php", data: {
      "business_id": businessId,
      "user_id": userId,
    });
    return response.data;
  }

  // Search for businesses by query
  Future<List<dynamic>> searchBusinesses(String query) async {
    final response = await _dio.get("business/search_businesses.php", queryParameters: {
      "query": query,
    });

    if (response.data['status'] == 'success') {
      return response.data['data'];
    } else {
      throw Exception('İşletmeler ararken bir hata oluştu');
    }
  }

  // Get businesses by category
  Future<List<dynamic>> getBusinessesByCategory(String category) async {
    final response = await _dio.get("business/get_businesses_by_category.php", queryParameters: {
      "category": category,
    });

    if (response.data['status'] == 'success') {
      return response.data['data'];
    } else {
      throw Exception('Kategoriye göre işletmeler alınamadı');
    }
  }

  // Toggle favorite business for a user
  Future<Map<String, dynamic>> toggleFavoriteBusiness(int businessId, int userId) async {
    final response = await _dio.post("business/toggle_favorite_business.php", data: {
      "business_id": businessId,
      "user_id": userId,
    });
    return response.data;
  }

  // Add a new business
  Future<Map<String, dynamic>> addBusiness(FormData formData) async {
    final response = await _dio.post("business/add_business.php", data: formData);
    return response.data;
  }
}
