import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/domain/comment/model/comment_request.dart';

abstract class CommentRepository {
  Future<ResultState<List<Comment>>> getComments(String postId);
  Future<ResultState<bool>> create(String userId, CommentRequest request);
  Future<ResultState<bool>> update(
    String userId,
    int commentId,
    CommentRequest request,
  );
  Future<ResultState<bool>> delete(String userId, int commentId);
}
