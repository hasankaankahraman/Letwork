import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'package:letwork/features/business/cubit/update_business_state.dart';

class UpdateBusinessCubit extends Cubit<UpdateBusinessState> {
  final BusinessRepository _repository;

  UpdateBusinessCubit(this._repository) : super(UpdateBusinessInitial());

  Future<void> fetchBusinessDetails(int businessId) async {
    emit(BusinessDetailsLoading());

    try {
      final BusinessDetailModel business = await _repository.getBusinessDetails(businessId);
      emit(BusinessDetailsLoaded(business));
    } catch (e) {
      emit(UpdateBusinessError('İşletme detayları yüklenemedi: ${e.toString()}'));
    }
  }

  Future<void> updateBusiness({
    required int businessId,
    required int userId,
    required String name,
    required String description,
    required String category,
    String? subCategory,
    bool isCorporate = false,
    String? openTime,
    String? closeTime,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    emit(UpdateBusinessLoading());

    try {
      // Create form data from the parameters
      final formData = FormData.fromMap({
        'business_id': businessId.toString(),
        'user_id': userId.toString(),
        'name': name,
        'description': description,
        'category': category,
        if (subCategory != null) 'sub_category': subCategory,
        'is_corporate': isCorporate ? '1' : '0',
        if (openTime != null) 'open_time': openTime,
        if (closeTime != null) 'close_time': closeTime,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (address != null) 'address': address,
      });

      final response = await _repository.updateBusiness(formData);

      if (response['status'] == 'success') {
        emit(UpdateBusinessSuccess(
            response['message'] ?? 'İşletme başarıyla güncellendi',
            businessId
        ));
      } else {
        emit(UpdateBusinessError(response['message'] ?? 'Güncelleme sırasında bir hata oluştu'));
      }
    } catch (e) {
      emit(UpdateBusinessError('Bağlantı hatası: ${e.toString()}'));
    }
  }

  Future<void> updateBusinessFull({
    required int businessId,
    required int userId,
    required String name,
    required String description,
    required String category,
    String subCategory = '',
    bool isCorporate = false,
    String openTime = '',
    String closeTime = '',
    double latitude = 0.0,
    double longitude = 0.0,
    String address = '',
    List<Map<String, dynamic>>? menu,
    List<Map<String, String>>? services,
    MultipartFile? profileImage,
    List<MultipartFile>? detailImages,
  }) async {
    emit(UpdateBusinessLoading());

    try {
      final response = await _repository.updateBusinessFull(
          businessId,
          userId,
          name,
          description,
          category,
          subCategory,
          isCorporate,
          openTime,
          closeTime,
          latitude,
          longitude,
          address,
          menu,
          services,
          profileImage,
          detailImages
      );

      if (response['status'] == 'success') {
        emit(UpdateBusinessSuccess(
            response['message'] ?? 'İşletme başarıyla güncellendi',
            businessId
        ));
      } else {
        emit(UpdateBusinessError(response['message'] ?? 'Güncelleme sırasında bir hata oluştu'));
      }
    } catch (e) {
      emit(UpdateBusinessError('Bağlantı hatası: ${e.toString()}'));
    }
  }

  Future<void> updateBusinessServices({
    required int businessId,
    required int userId,
    required List<Map<String, String>> services,
  }) async {
    emit(UpdateBusinessLoading());

    try {
      final response = await _repository.updateBusinessServices(businessId, userId, services);

      if (response['status'] == 'success') {
        emit(UpdateBusinessSuccess(
            response['message'] ?? 'Hizmetler başarıyla güncellendi',
            businessId
        ));
      } else {
        emit(UpdateBusinessError(response['message'] ?? 'Hizmetler güncellenirken bir hata oluştu'));
      }
    } catch (e) {
      emit(UpdateBusinessError('Bağlantı hatası: ${e.toString()}'));
    }
  }

  Future<void> updateBusinessImages({
    required int businessId,
    required int userId,
    MultipartFile? profileImage,
    List<MultipartFile>? detailImages,
  }) async {
    emit(UpdateBusinessLoading());

    try {
      FormData formData = FormData();
      formData.fields.add(MapEntry('business_id', businessId.toString()));
      formData.fields.add(MapEntry('user_id', userId.toString()));

      if (profileImage != null) {
        formData.files.add(MapEntry('profile_image', profileImage));
      }

      if (detailImages != null && detailImages.isNotEmpty) {
        for (int i = 0; i < detailImages.length; i++) {
          formData.files.add(MapEntry('detail_images[$i]', detailImages[i]));
        }
      }

      final response = await _repository.updateBusiness(formData);

      if (response['status'] == 'success') {
        emit(UpdateBusinessSuccess(
            response['message'] ?? 'Resimler başarıyla güncellendi',
            businessId
        ));
      } else {
        emit(UpdateBusinessError(response['message'] ?? 'Resimler güncellenirken bir hata oluştu'));
      }
    } catch (e) {
      emit(UpdateBusinessError('Bağlantı hatası: ${e.toString()}'));
    }
  }
}