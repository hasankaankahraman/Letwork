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
  Future<dynamic> getBusinessDetails(int businessId) async {
    try {
      final response = await _service.fetchBusinessDetail(businessId.toString());
      return response;
    } catch (e) {
      throw Exception('İşletme detayları alınırken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final response = await _service.fetchAllBusinesses();
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response as List).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('İşletmeler alınırken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getUserBusinesses(int userId) async {
    try {
      final response = await _service.fetchUserBusinesses(userId);
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response as List).map((business) => BusinessModel.fromJson(business)).toList();
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
      return (response as List).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('İşletmeler ararken bir hata oluştu: $e');
    }
  }

  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    try {
      final response = await _service.getBusinessesByCategory(category);
      // Dönüşüm işlemi: List<dynamic> -> List<BusinessModel>
      return (response as List).map((business) => BusinessModel.fromJson(business)).toList();
    } catch (e) {
      throw Exception('Kategoriye göre işletmeler alınırken bir hata oluştu: $e');
    }
  }
}