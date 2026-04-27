import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/post.dart';
import '../model/post_request.dart';

class CreatePostUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  const CreatePostUseCase(this._postRepository, this._authRepository);

  Future<ResultState<Post>> invoke(PostRequest request) async {
    if (request.title.isEmpty) {
      return const Error("Title is required.");
    }

    if (request.imageFile == null) {
      return const Error("An image required for new post.");
    }

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      return const Error("Session expired. Please sign in again.");
    }

    final result = await _postRepository.create(user.id, request);

    return switch (result) {
      Success(data: final post) => Success(post),
      Error(error: final key) => Error(switch (key) {
        "POST_CREATE_FAILED" => "Failed to upload post.",
        "POST_CREATED_BUT_NOT_READABLE" =>
          "Post uploaded, but failed to refresh post data.",
        _ => key,
      }),
    };
  }
}
