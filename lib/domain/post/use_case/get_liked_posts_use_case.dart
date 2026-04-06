import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';

class GetLikedPostsUseCase {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;

  const GetLikedPostsUseCase(this._postRepository, this._authRepository);

  Future<ResultState<List<Post>>> invoke({
    required int offset,
    required int limit,
  }) async {
    final user = _authRepository.getCurrentUser();
    if (user == null) return const Error("USER_NOT_FOUND");

    return _postRepository.getLikedPosts(user.id, offset: offset, limit: limit);
  }
}
