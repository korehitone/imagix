import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';
import '../repository/post_repository.dart';

class DeletePostUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  const DeletePostUseCase(this._postRepository, this._authRepository);

  Future<ResultState<bool>> invoke(String postId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }
    final result = await _postRepository.delete(user.id, postId);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "POST_DELETE_FAILED_OR_DENIED"
            ? "Delete failed. Access denied."
            : key,
      ),
    };
  }
}
