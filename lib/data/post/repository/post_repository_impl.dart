import 'dart:io';

import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/post/model/post_response.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostRepositoryImpl implements PostRepository {
  final SupabaseClient _client;

  PostRepositoryImpl(this._client);

  @override
  Future<ResultState<List<Post>>> getPosts({
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);
      return Success(
        response
            .decodeList(PostResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<Post>> getPost(String postId) async {
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .eq('id', postId)
          .maybeSingle();

      final post = response.decodeSingle(PostResponse.fromJson)?.toDomain();

      if (post == null) {
        return const Error("POST_NOT_FOUND");
      }
      return Success(post);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<List<Post>>> getUserPosts(
    String userId, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);
      return Success(
        response
            .decodeList(PostResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<List<Post>>> getLikedPosts(
    String userId, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .eq('is_liked', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return Success(
        response
            .decodeList(PostResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<List<Post>>> getPostsByQuery(
    String query, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('post_list_view')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);
      return Success(
        response
            .decodeList(PostResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  Future<String> _uploadImage(File imageFile, String userId) async {
    final String extension = imageFile.path.split('.').last;
    final String filename =
        '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final path = '$userId/post/$filename';

    await _client.storage
        .from('imagix')
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _client.storage.from('imagix').getPublicUrl(path);
  }

  @override
  Future<ResultState<Post>> create(String userId, PostRequest request) async {
    try {
      final file = request.imageFile!;

      final String imageUrl = await _uploadImage(file, userId);

      final response = await _client
          .from('posts')
          .insert({
            'user_id': userId,
            'image': imageUrl,
            'title': request.title,
            'description': request.description,
          })
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("POST_CREATE_FAILED");
      }

      final viewResponse = await _client
          .from('post_list_view')
          .select()
          .eq('id', response['id'])
          .single();
      return Success(PostResponse.fromJson(viewResponse).toDomain());
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> update(
    String userId,
    String postId,
    PostRequest request,
  ) async {
    try {
      final response = await _client
          .from('posts')
          .update({'title': request.title, 'description': request.description})
          .eq('id', postId)
          .eq('user_id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("POST_UPDATE_FAILED_OR_DENIED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> delete(String userId, String postId) async {
    try {
      final response = await _client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', userId)
          .select('id')
          .maybeSingle();

      if (response == null) {
        return const Error("POST_DELETE_FAILED_OR_DENIED");
      }

      return Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> toggleLike(String userId, String postId) async {
    try {
      final existing = await _client
          .from('likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();
      if (existing == null) {
        final response = await _client
            .from('likes')
            .insert({'post_id': postId, 'user_id': userId})
            .select('id')
            .maybeSingle();

        if (response == null) return const Error("LIKE_FAILED");
        return const Success(true); // Status sekarang: Liked
      } else {
        await _client
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        return const Success(false); // Status sekarang: Unliked
      }
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
