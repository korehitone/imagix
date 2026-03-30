import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/post_request.dart';
import '../repository/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  const UpdatePostUseCase(this._postRepository, this._authRepository);

  Future<ResultState<bool>> invoke(String postId, PostRequest request) async {
    if (request.title.isEmpty) {
      return const Error("Title can not be empty.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _postRepository.update(user.id, postId, request);
    return switch (result) {
      Success(data: final d) => Success(d),
      Error(error: final key) => Error(
        key == "POST_UPDATE_FAILED_OR_DENIED"
            ? "Update failed. Access denied."
            : key,
      ),
    };
  }
}
