import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/collection/model/collection_response.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final SupabaseClient _client;

  CollectionRepositoryImpl(this._client);

  @override
  Future<ResultState<List<Collection>>> getUserCollections(
    String userId, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('collection_list_view')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return Success(
        response
            .decodeList(CollectionListViewResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<List<Collection>>> getUserCollectionsWithSaved(
    String userId,
    String postId,
  ) async {
    try {
      final response = await _client
          .from('collection_list_view')
          .select()
          .eq('user_id', userId);

      final savedItems = await _client
          .from('collection_item_list_view')
          .select('collection_id')
          .eq('id', postId);

      final Set<String> savedIds = (savedItems as List)
          .map((e) => e['collection_id'].toString())
          .toSet();

      return Success(
        response.decodeList(CollectionListViewResponse.fromJson).map((dto) {
          final domain = dto.toDomain();

          return domain.copyWith(isSaved: savedIds.contains(domain.id));
        }).toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> create(String userId, String title) async {
    try {
      final response = await _client
          .from('collections')
          .insert({'user_id': userId, 'title': title})
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("CREATE_FAILED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> update(
    String userId,
    String collectionId,
    String title,
  ) async {
    try {
      final response = await _client
          .from('collections')
          .update({'title': title})
          .eq('id', collectionId)
          .eq('user_id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        return const Error("ACTION_DENIED_OR_NOT_FOUND");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> delete(String userId, String collectionId) async {
    try {
      final response = await _client
          .from('collections')
          .delete()
          .eq('id', collectionId)
          .eq('user_id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("ACTION_DENIED_OR_NOT_FOUND");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
