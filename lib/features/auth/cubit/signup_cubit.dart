import 'package:bloc/bloc.dart';
import 'package:letwork/features/auth/repository/auth_repository.dart';
import 'package:meta/meta.dart';


part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<void> signup({
    required String fullname,
    required String username,
    required String email,
    required String password,
  }) async {
    emit(SignupLoading());

    try {
      final data = await _authRepository.signup(
        fullname: fullname,
        username: username,
        email: email,
        password: password,
      );

      if (data['status'] == 'success') {
        emit(SignupSuccess(message: data['message']));
      } else {
        emit(SignupError(message: data['message']));
      }
    } catch (e) {
      emit(SignupError(message: "Kayıt sırasında bir hata oluştu."));
    }
  }
}
