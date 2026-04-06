import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/model/collection_item_response.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionItemRepositoryImpl implements CollectionItemRepository {
  final SupabaseClient _client;

  CollectionItemRepositoryImpl(this._client);

  @override
  Future<ResultState<List<CollectionItem>>> getItemsByCollection(
    String collectionId, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('collection_item_list_view')
          .select()
          .eq('collection_id', collectionId)
          .order('added_at', ascending: false)
          .range(offset, offset + limit - 1);

      return Success(
        response
            .decodeList(CollectionItemListViewResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> create(String collectionId, String postId) async {
    try {
      final response = await _client
          .from('collection_items')
          .insert({'collection_id': collectionId, 'post_id': postId})
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("ITEM_CREATE_FAILED");
      }
      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> delete(int itemId) async {
    try {
      final response = await _client
          .from('collection_items')
          .delete()
          .eq('id', itemId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("ITEM_NOT_FOUND");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
