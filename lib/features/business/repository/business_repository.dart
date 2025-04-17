import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/business_service.dart';

class BusinessRepository {
  final BusinessService _service = BusinessService();

  // Create operations
  Future<Map<String, dynamic>> addBusiness(FormData formData) async {
    try {
      final response = await _service.addBusiness(formData);
      return response;
    } catch (e) {
      throw Exception('İşletme eklenirken bir hata oluştu: $e');
    }
  }

  // Read operations
  Future<BusinessDetailModel> getBusinessDetail(int businessId) async {
    try {
      final response = await _service.fetchBusinessDetail(businessId.toString());
      return response;
    } catch (e) {
      throw Exception('İşletme bilgileri alınırken bir hata oluştu: $e');
    }
  }

  // This method is needed for UpdateBusinessCubit
  Future<BusinessDetailModel> getBusinessDetails(int businessId) async {
    try {
      final response = await _service.fetchBusinessDetail(businessId.toString());
      return response;
    } catch (e) {
      throw Exception('İşletme detayları alınırken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      return await _service.fetchAllBusinesses();
    } catch (e) {
      throw Exception('İşletmeler alınırken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getUserBusinesses(int userId) async {
    try {
      final response = await _service.fetchUserBusinesses(userId);
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('Kullanıcıya ait işletmeler alınırken bir hata oluştu: $e');
    }
  }

  // Update operations
  Future<Map<String, dynamic>> updateBusiness(FormData formData) async {
    try {
      final response = await _service.updateBusiness(formData);
      return response;
    } catch (e) {
      throw Exception('İşletme güncellenirken bir hata oluştu: $e');
    }
  }

  // Update business with complete information
  Future<Map<String, dynamic>> updateBusinessFull(
      int businessId,
      int userId,
      String name,
      String description,
      String category,
      String subCategory,
      bool isCorporate,
      String openTime,
      String closeTime,
      double latitude,
      double longitude,
      String address,
      List<Map<String, dynamic>>? menu,
      List<Map<String, dynamic>>? services,
      MultipartFile? profileImage,
      List<MultipartFile>? detailImages) async {
    try {
      FormData formData = FormData();

      // Temel bilgiler
      formData.fields.add(MapEntry('business_id', businessId.toString()));
      formData.fields.add(MapEntry('user_id', userId.toString()));
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('category', category));
      formData.fields.add(MapEntry('sub_category', subCategory));
      formData.fields.add(MapEntry('is_corporate', isCorporate ? '1' : '0'));
      formData.fields.add(MapEntry('open_time', openTime));
      formData.fields.add(MapEntry('close_time', closeTime));
      formData.fields.add(MapEntry('latitude', latitude.toString()));
      formData.fields.add(MapEntry('longitude', longitude.toString()));
      formData.fields.add(MapEntry('address', address));

      // Menu bilgisi varsa ekle
      if (menu != null) {
        formData.fields.add(MapEntry('menu', jsonEncode(menu)));
      }

      // Hizmetler varsa ekle
      if (services != null) {
        formData.fields.add(MapEntry('services', jsonEncode(services)));
      }

      // Profil resmi varsa ekle
      if (profileImage != null) {
        formData.files.add(MapEntry('profile_image', profileImage));
      }

      // Detay resimleri varsa ekle
      if (detailImages != null && detailImages.isNotEmpty) {
        for (int i = 0; i < detailImages.length; i++) {
          formData.files.add(MapEntry('detail_images[$i]', detailImages[i]));
        }
      }

      final response = await _service.updateBusiness(formData);
      return response;
    } catch (e) {
      throw Exception('İşletme güncellenirken bir hata oluştu: $e');
    }
  }

  // Update only business services
  Future<Map<String, dynamic>> updateBusinessServices(int businessId, int userId, List<Map<String, dynamic>> services) async {
    try {
      return await _service.updateBusinessServices(businessId, userId, services);
    } catch (e) {
      throw Exception('İşletme hizmetleri güncellenirken bir hata oluştu: $e');
    }
  }

  // Delete operations
  Future<Map<String, dynamic>> deleteBusiness(int businessId, int userId) async {
    try {
      final response = await _service.deleteBusiness(businessId, userId);
      return response;
    } catch (e) {
      throw Exception('İşletme silinirken bir hata oluştu: $e');
    }
  }

  // Additional operations
  Future<List<BusinessModel>> searchBusinesses(String query) async {
    try {
      final response = await _service.searchBusinesses(query);
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('İşletmeler ararken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    try {
      final response = await _service.getBusinessesByCategory(category);
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('Kategoriye göre işletmeler alınırken bir hata oluştu: $e');
    }
  }
}