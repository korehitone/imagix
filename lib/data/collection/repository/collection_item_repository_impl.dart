import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/model/view/collection_item_list_view_response.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionItemRepositoryImpl extends CollectionItemRepository {
  final SupabaseClient _client;

  CollectionItemRepositoryImpl(this._client);

  @override
  Stream<ResultState<List<CollectionItem>>> getItemsByCollection(
    String collectionId,
  ) async* {
    yield const Loading();
    try {
      final response = await _client
          .from('collection_item_list_view')
          .select()
          .eq('collection_id', collectionId)
          .order('added_at', ascending: false);

      yield Success(
        response
            .decodeList(CollectionItemListViewResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
