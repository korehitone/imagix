import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/profile.dart';

class GetProfileUseCase {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  const GetProfileUseCase(this._profileRepository, this._authRepository);
  Future<ResultState<Profile>> invoke(String userId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }
    final result = await _profileRepository.getProfile(user.id, userId);

    if (result is Success<Profile>) {
      if (userId == user.id) {
        final local = _authRepository.getLocalUser();
        if (local != null) {
          _authRepository.saveLocalUser(
            local.copyWith(
              id: result.data.id,
              username: result.data.username,
              photo: result.data.photo,
              bio: result.data.bio,
              totalPosts: result.data.totalPosts,
              totalCollections: result.data.totalCollections,
              totalFollowers: result.data.totalFollowers,
              totalFollowings: result.data.totalFollowings,
            ),
          );
        }
      }
    }

    return switch (result) {
      Success(data: final p) => Success(p),
      Error(error: final key) => Error(
        key == "PROFILE_NOT_FOUND" ? "User profile not found." : key,
      ),
    };
  }
}
