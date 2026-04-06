import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/profile_request.dart';

class UpdateProfileUseCase {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  const UpdateProfileUseCase(this._profileRepository, this._authRepository);

  Future<ResultState<bool>> invoke(ProfileRequest request) async {
    if (request.username.isEmpty) {
      return const Error("Username can not be empty.");
    }

    final usernameRegex = RegExp(r'^[A-Za-z0-9._]+$');
    if (!usernameRegex.hasMatch(request.username)) {
      return const Error(
        "Username can only contain letters, numbers, underscore (_) and dot (.).",
      );
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _profileRepository.updateProfile(user.id, request);

    if (result is Success<UserProfile>) {
      await _authRepository.saveLocalUser(result.data);
    }
    return switch (result) {
      Success() => const Success(true),
      Error(error: final key) => Error(
        key == "UPDATE_PROFILE_FAILED" ? "Failed to update profile." : key,
      ),
    };
  }
}
