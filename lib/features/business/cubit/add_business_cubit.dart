import 'package:bloc/bloc.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'package:meta/meta.dart';


part 'add_business_state.dart';

class AddBusinessCubit extends Cubit<AddBusinessState> {
  AddBusinessCubit() : super(AddBusinessInitial());

  final _repository = BusinessRepository();

  Future<void> addBusiness(Map<String, dynamic> formData) async {
    emit(AddBusinessLoading());
    try {
      final response = await _repository.addBusiness(formData);
      if (response['status'] == 'success') {
        emit(AddBusinessSuccess(message: response['message']));
      } else {
        emit(AddBusinessError(message: response['message']));
      }
    } catch (e) {
      emit(AddBusinessError(message: 'İşletme eklenirken hata oluştu.'));
    }
  }
}
