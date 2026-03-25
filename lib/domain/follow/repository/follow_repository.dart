import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/follow/model/follow.dart';

abstract class FollowRepository {
  Stream<ResultState<List<Follow>>> getFollowing(String userId);
  Stream<ResultState<List<Follow>>> getFollowers(String userId);
}
