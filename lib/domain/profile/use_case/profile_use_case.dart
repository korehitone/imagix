import 'package:imagix/domain/profile/use_case/get_profile_use_case.dart';
import 'package:imagix/domain/profile/use_case/update_profile_use_case.dart';

class ProfileUseCase {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfile;

  const ProfileUseCase({required this.getProfile, required this.updateProfile});
}
