import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/follow/model/follow_response.dart';
import 'package:imagix/domain/follow/model/follow.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowRepositoryImpl implements FollowRepository {
  final SupabaseClient _client;

  FollowRepositoryImpl(this._client);

  @override
  Future<ResultState<List<Follow>>> getFollowers(String userId) async {
    try {
      final response = await _client
          .from('follows_view')
          .select()
          .eq('following_id', userId)
          .order('created_at', ascending: false);
      return Success(
        response
            .decodeList(FollowResponse.fromJson)
            .map(
              (dto) => Follow(
                userId: dto.followerId,
                username: dto.followerUsername,
                photo: dto.followerPhoto,
                isFollowing: dto.isFollowing,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<List<Follow>>> getFollowing(String userId) async {
    try {
      final response = await _client
          .from('follows_view')
          .select()
          .eq('follower_id', userId)
          .order('created_at', ascending: false);
      return Success(
        response
            .decodeList(FollowResponse.fromJson)
            .map(
              (dto) => Follow(
                userId: dto.followingId,
                username: dto.followingUsername,
                photo: dto.followingPhoto,
                isFollowing: dto.isFollowing,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> toggleFollow(
    String currentUserId,
    String followingId,
  ) async {
    try {
      final existing = await _client
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', followingId)
          .maybeSingle();

      if (existing == null) {
        // INSERT (Follow)
        final response = await _client
            .from('follows')
            .insert({'follower_id': currentUserId, 'following_id': followingId})
            .select('follower_id')
            .maybeSingle();

        if (response == null) {
          return const Error("FOLLOW_ACTION_FAILED");
        }
        return const Success(true);
      } else {
        // DELETE (Unfollow)
        await _client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', followingId);
        return const Success(false);
      }
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<ResultState<bool>> removeFollower(
    String currentUserId,
    String followerId,
  ) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', currentUserId);

      return const Success(true);
    } catch (e) {
      return Error(ExceptionHandler.handle(e));
    }
  }
}
