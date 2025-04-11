import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'package:meta/meta.dart';

part 'add_business_state.dart';

class AddBusinessCubit extends Cubit<AddBusinessState> {
  AddBusinessCubit() : super(AddBusinessInitial());

  final _repository = BusinessRepository();

  Future<void> addBusiness(FormData formData) async {
    emit(AddBusinessLoading());
    try {
      final response = await _repository.addBusiness(formData);
      if (response['status'] == 'success') {
        final String businessId = response['data']['business_id'].toString();
        emit(AddBusinessSuccess(message: response['message'], businessId: businessId));
      } else {
        emit(AddBusinessError(message: response['message']));
      }
    } catch (e) {
      emit(AddBusinessError(message: 'İşletme eklenirken hata oluştu.'));
    }
  }
}
