import 'package:imagix/domain/post/repository/post_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/post.dart';

class GetPostsUseCase {
  final PostRepository _repository;

  const GetPostsUseCase(this._repository);

  Future<ResultState<List<Post>>> invoke() async => _repository.getPosts();
}
