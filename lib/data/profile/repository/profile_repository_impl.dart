import 'dart:io';

import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/profile/model/profile_response.dart';
import 'package:imagix/domain/common/model/user_profile.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/model/profile_request.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<ResultState<List<Profile>>> getProfilesByQuery(
    String query, {
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await _client
          .from('profile_view')
          .select()
          .or('username.ilike.%$query%')
          .range(offset, offset + limit - 1);
      return Success(
        response
            .decodeList(ProfileResponse.fromJson)
            .map((dto) => dto.toDomain())
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<Profile>> getProfile(
    String currentAuthId,
    String userId,
  ) async {
    try {
      final response = await _client
          .from('profile_view')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final profile = response
          .decodeSingle(ProfileResponse.fromJson)
          ?.toDomain();

      if (profile == null) {
        return const Error("PROFILE_NOT_FOUND");
      }

      return Success(profile);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  Future<String> _upload(File photo, String userId) async {
    final extension = photo.path.split('.').last;
    final filename = '$userId.$extension';
    final path = '$userId/profile/$filename';

    await _client.storage
        .from('imagix')
        .upload(
          path,
          photo,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );

    return _client.storage.from('imagix').getPublicUrl(path);
  }

  @override
  Future<ResultState<UserProfile>> updateProfile(
    String userId,
    ProfileRequest request,
  ) async {
    try {
      String? photoUrl;
      if (request.photo != null) {
        photoUrl = await _upload(request.photo!, userId);
      }

      final Map<String, dynamic> update = {
        'username': request.username,
        'bio': request.bio,
        if (photoUrl != null) 'photo': photoUrl,
      };

      final response = await _client
          .from('users')
          .update(update)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (response == null) {
        return const Error("UPDATE_PROFILE_FAILED");
      }

      return Success(UserProfile.fromJson(response));
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
