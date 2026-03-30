import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';

import '../../../core/network/result_state.dart';

class RemoveFollowerUseCase {
  final FollowRepository _followRepository;
  final AuthRepository _authRepository;

  const RemoveFollowerUseCase(this._followRepository, this._authRepository);

  Future<ResultState<bool>> invoke(String followerId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    return _followRepository.removeFollower(user.id, followerId);
  }
}
