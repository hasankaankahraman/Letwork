import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'package:letwork/features/business/cubit/update_business_state.dart';

class UpdateBusinessCubit extends Cubit<UpdateBusinessState> {
  final BusinessRepository _repository;

  UpdateBusinessCubit(this._repository) : super(UpdateBusinessInitial());

  Future<void> fetchBusinessDetails(int businessId) async {
    emit(BusinessDetailsLoading());

    try {
      final business = await _repository.getBusinessDetails(businessId);
      emit(BusinessDetailsLoaded(business));
    } catch (e) {
      emit(UpdateBusinessError('İşletme detayları yüklenemedi: ${e.toString()}'));
    }
  }

  Future<void> updateBusiness({
    required int businessId,
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required String website,
  }) async {
    emit(UpdateBusinessLoading());

    try {
      // Create form data from the parameters
      final formData = FormData.fromMap({
        'business_id': businessId.toString(),
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
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
}