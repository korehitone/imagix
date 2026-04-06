import 'package:imagix/domain/post/repository/post_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/post.dart';

class GetPostsUseCase {
  final PostRepository _repository;

  const GetPostsUseCase(this._repository);

  Future<ResultState<List<Post>>> invoke({
    required int offset,
    required int limit,
  }) async => _repository.getPosts(offset: offset, limit: limit);
}
