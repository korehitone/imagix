import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';

import '../../../core/network/result_state.dart';

class ToggleLikeUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  const ToggleLikeUseCase(this._postRepository, this._authRepository);

  Future<ResultState<bool>> invoke(String postId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }
    final result = await _postRepository.toggleLike(user.id, postId);
    return switch (result) {
      Success(data: final isLiked) => Success(isLiked),
      Error(error: final key) => Error(
        key == "LIKE_FAILED" ? "Failed to like post." : key,
      ),
    };
  }
}
