import 'package:letwork/data/services/profile_service.dart';

class ProfileRepository {
  final ProfileService profileService;

  ProfileRepository(this.profileService);

  Future<Map<String, dynamic>> updateProfile({
    required int id,
    required String fullname,
    required String username,
    required String email,
    String? password,
  }) {
    return profileService.updateProfile(
      id: id,
      fullname: fullname,
      username: username,
      email: email,
      password: password,
    );
  }
}
