import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/post/model/view/post_list_view_response.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepositoryImpl extends PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  @override
  Stream<ResultState<List<Post>>> getFeeds() async* {
    yield const Loading();
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .order('created_at', ascending: false);
      yield Success(
        response
            .decodeList(PostListViewResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
