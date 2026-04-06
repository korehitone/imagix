import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';

class GetUserPostsUseCase {
  final PostRepository _repository;

  GetUserPostsUseCase(this._repository);

  Future<ResultState<List<Post>>> invoke(
    String userId, {
    required int offset,
    required int limit,
  }) => _repository.getUserPosts(userId, offset: offset, limit: limit);
}
