import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/comment/mapper/comment_mapper.dart';
import 'package:imagix/data/comment/model/comment_response.dart';
import 'package:imagix/domain/comment/model/comment.dart';
import 'package:imagix/domain/comment/model/comment_request.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepositoryImpl implements CommentRepository {
  final SupabaseClient _client;

  CommentRepositoryImpl(this._client);

  @override
  Future<ResultState<List<Comment>>> getComments(String postId) async {
    try {
      final response = await _client
          .from('comment_list_view')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      final flatComments = response
          .decodeList(CommentResponse.fromJson)
          .map((dto) => dto.toDomain())
          .toList();

      final nestedComments = CommentMapper.toNested(flatComments);
      return Success(nestedComments);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      return Error(error);
    }
  }

  @override
  Future<ResultState<bool>> create(
    String userId,
    CommentRequest request,
  ) async {
    try {
      final response = await _client
          .from('comments')
          .insert({
            'post_id': request.postId,
            'user_id': userId,
            'parent_id': request.parentId,
            'comment': request.comment,
          })
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("COMMENT_CREATE_FAILED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> update(
    String userId,
    int commentId,
    CommentRequest request,
  ) async {
    try {
      final response = await _client
          .from('comments')
          .update({'comment': request.comment})
          .eq('id', commentId)
          .eq('user_id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("COMMENT_NOT_FOUND_OR_DENIED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> delete(String userId, int commentId) async {
    try {
      final response = await _client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("COMMENT_NOT_FOUND_OR_DENIED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
