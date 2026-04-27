import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';

abstract class PostRepository {
  Future<ResultState<List<Post>>> getPosts({
    required int offset,
    required int limit,
  });
  Future<ResultState<Post>> getPost(String postId);
  Future<ResultState<List<Post>>> getLikedPosts({
    required int offset,
    required int limit,
  });
  Future<ResultState<List<Post>>> getPostsByQuery(
    String query, {
    required int offset,
    required int limit,
  });
  Future<ResultState<List<Post>>> getUserPosts(
    String userId, {
    required int offset,
    required int limit,
  });

  Future<ResultState<Post>> create(String userId, PostRequest request);

  Future<ResultState<bool>> update(
    String userId,
    String postId,
    PostRequest request,
  );

  Future<ResultState<bool>> delete(String userId, String postId);

  Future<ResultState<bool>> toggleLike(String userId, String postId);
}
