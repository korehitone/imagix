import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/follow/model/view/follow_view_response.dart';
import 'package:imagix/domain/follow/model/follow.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowRepositoryImpl extends FollowRepository {
  final SupabaseClient _client;

  FollowRepositoryImpl(this._client);

  @override
  Stream<ResultState<List<Follow>>> getFollowers(String userId) async* {
    yield const Loading();
    try {
      final response = await _client
          .from('follows_view')
          .select()
          .eq('following_id', userId)
          .order('created_at', ascending: false);
      yield Success(
        response
            .decodeList(FollowViewResponse.fromJson)
            .map(
              (dto) => Follow(
                followId: dto.followId,
                userId: dto.followerId,
                username: dto.followerUsername,
                photo: dto.followerPhoto,
              ),
            )
            .toList(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }

  @override
  Stream<ResultState<List<Follow>>> getFollowing(String userId) async* {
    yield const Loading();
    try {
      final response = await _client
          .from('follows_view')
          .select()
          .eq('follower_id', userId)
          .order('created_at', ascending: false);
      yield Success(
        response
            .decodeList(FollowViewResponse.fromJson)
            .map(
              (dto) => Follow(
                followId: dto.followId,
                userId: dto.followingId,
                username: dto.followingUsername,
                photo: dto.followingPhoto,
              ),
            )
            .toList(),
      );
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
