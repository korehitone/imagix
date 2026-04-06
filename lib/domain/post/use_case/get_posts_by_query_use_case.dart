import 'package:imagix/domain/post/repository/post_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/post.dart';

class GetPostsByQueryUseCase {
  final PostRepository _repository;
  const GetPostsByQueryUseCase(this._repository);
  Future<ResultState<List<Post>>> invoke(
    String query, {
    required int offset,
    required int limit,
  }) async => _repository.getPostsByQuery(query, offset: offset, limit: limit);
}
