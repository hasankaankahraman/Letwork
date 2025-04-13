import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/features/profile/repository/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final BusinessService _businessService;
  final ProfileRepository _profileRepository;

  ProfileCubit(this._businessService, this._profileRepository)
      : super(ProfileInitial());

  Future<void> fetchMyBusinesses() async {
    emit(ProfileLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId")?.toString();

      if (userId == null) {
        throw Exception("Kullanıcı ID bulunamadı");
      }

      final allBusinesses = await _businessService.fetchAllBusinesses();
      final myBusinesses =
      allBusinesses.where((b) => b.userId == userId).toList();

      emit(ProfileLoaded(myBusinesses));
    } catch (e) {
      emit(ProfileError("Hata: ${e.toString()}"));
    }
  }

  Future<void> updateUserProfile({
    required String fullname,
    required String username,
    required String email,
    String? password,
  }) async {
    emit(ProfileUpdating());

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      if (userId == null) throw Exception("Kullanıcı ID bulunamadı");

      final response = await _profileRepository.updateProfile(
        id: userId,
        fullname: fullname,
        username: username,
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        await prefs.setString('fullname', fullname);
        await prefs.setString('username', username);
        await prefs.setString('email', email);

        emit(ProfileUpdated(message: response['message']));
      } else {
        emit(ProfileError(response['message']));
      }
    } catch (e) {
      emit(ProfileError("Hata: ${e.toString()}"));
    }
  }
}
