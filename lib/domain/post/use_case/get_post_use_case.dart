import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';

class GetPostUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  GetPostUseCase(this._postRepository, this._authRepository);

  Future<ResultState<Post>> invoke(String postId) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _postRepository.getPost(postId);
    return switch (result) {
      Success(data: final p) => Success(p),
      Error(error: final key) => Error(
        key == "POST_NOT_FOUND" ? "User profile not found." : key,
      ),
    };
  }
}
