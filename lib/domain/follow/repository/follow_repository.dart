import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/follow/model/follow.dart';

abstract class FollowRepository {
  Future<ResultState<List<Follow>>> getFollowing(String userId);
  Future<ResultState<List<Follow>>> getFollowers(String userId);
  Future<ResultState<bool>> toggleFollow(
    String currentUserId,
    String followingId,
  );
  Future<ResultState<bool>> removeFollower(
    String currentUserId,
    String followerId,
  );
}
