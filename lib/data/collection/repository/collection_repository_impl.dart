import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/model/view/collection_list_view_response.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepositoryImpl extends CollectionRepository {
  final SupabaseClient _client;

  CollectionRepositoryImpl(this._client);

  @override
  Stream<ResultState<List<Collection>>> getUserCollections() async* {
    yield const Loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        yield Error(
          ExceptionHandler.handle(
            AuthException("Session expired, please sign in again."),
          ),
        );
        return;
      }

      final response = await _client
          .from('collection_list_view')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      yield Success(
        response
            .decodeList(CollectionListViewResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
