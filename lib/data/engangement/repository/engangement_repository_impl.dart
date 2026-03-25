import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/engangement/mapper/comment_mapper.dart';
import 'package:imagix/data/engangement/model/view/comment_list_view_response.dart';
import 'package:imagix/domain/engangement/model/comment.dart';
import 'package:imagix/domain/engangement/repository/engangement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EngangementRepositoryImpl extends EngangementRepository {
  final SupabaseClient _client;

  EngangementRepositoryImpl(this._client);

  @override
  Stream<ResultState<List<Comment>>> getComments(String postId) async* {
    yield const Loading();
    try {
      final response = await _client
          .from('comment_list_view')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      final flatComments = response
          .decodeList(CommentListViewResponse.fromJson)
          .map((dto) => dto.toDomain())
          .toList();

      final nestedComments = CommentMapper.toNested(flatComments);
      yield Success(nestedComments);
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
