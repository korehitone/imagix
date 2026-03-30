import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';

import '../../../core/network/result_state.dart';

class ToggleFollowUseCase {
  final FollowRepository _followRepository;
  final AuthRepository _authRepository;

  const ToggleFollowUseCase(this._followRepository, this._authRepository);

  Future<ResultState<bool>> invoke(String followingId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }
    final result = await _followRepository.toggleFollow(user.id, followingId);
    return switch (result) {
      Success(data: final isFollowed) => Success(isFollowed),
      Error(error: final key) => Error(
        key == "FOLLOW_ACTION_FAILED"
            ? "Failed to follow. Please try again later."
            : key,
      ),
    };
  }
}
