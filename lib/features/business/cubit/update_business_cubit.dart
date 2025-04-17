import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/services/category_service.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'update_business_state.dart';

class UpdateBusinessCubit extends Cubit<UpdateBusinessState> {
  final BusinessRepository _repository;
  final CategoryService _categoryService;

  UpdateBusinessCubit(this._repository, this._categoryService)
      : super(UpdateBusinessInitial());

  late BusinessDetailModel _businessData;
  BusinessDetailModel get businessData => _businessData;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  Future<void> fetchInitialData(int businessId) async {
    emit(BusinessDetailsLoading());

    try {
      final detail = await _repository.getBusinessDetails(businessId);
      final catData = await _categoryService.fetchGroupedCategories();

      _businessData = detail;
      _categories = catData;

      emit(BusinessDetailsLoaded(detail));
    } catch (e) {
      emit(UpdateBusinessError('Veri alınırken hata oluştu: ${e.toString()}'));
    }
  }

  Future<void> updateBusinessFull({
    required int businessId,
    required int userId,
    required String name,
    required String description,
    required String category,
    required String subCategory,
    required bool isCorporate,
    required String openTime,
    required String closeTime,
    required double latitude,
    required double longitude,
    required String address,
    required List<Map<String, String>> services,
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
        null,
        services,
        profileImage,
        detailImages,
      );

      if (response['status'] == 'success') {
        emit(UpdateBusinessSuccess(
            response['message'] ?? "İşletme başarıyla güncellendi", businessId));
      } else {
        emit(UpdateBusinessError(response['message'] ?? "Güncelleme başarısız"));
      }
    } catch (e) {
      emit(UpdateBusinessError("Bağlantı hatası: ${e.toString()}"));
    }
  }
}
