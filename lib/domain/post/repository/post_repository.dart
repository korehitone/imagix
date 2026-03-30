import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';

abstract class PostRepository {
  Future<ResultState<List<Post>>> getPosts();

  Future<ResultState<Post>> create(String userId, PostRequest request);

  Future<ResultState<bool>> update(
    String userId,
    String postId,
    PostRequest request,
  );

  Future<ResultState<bool>> delete(String userId, String postId);

  Future<ResultState<bool>> toggleLike(String userId, String postId);
}
