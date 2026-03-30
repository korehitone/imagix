import 'package:imagix/domain/follow/use_case/get_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/get_following_use_case.dart';
import 'package:imagix/domain/follow/use_case/remove_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/toggle_follow_use_case.dart';

class FollowUseCase {
  final GetFollowerUseCase getFollower;
  final GetFollowingUseCase getFollowing;
  final RemoveFollowerUseCase removeFollower;
  final ToggleFollowUseCase toggleFollow;

  const FollowUseCase({
    required this.getFollower,
    required this.getFollowing,
    required this.removeFollower,
    required this.toggleFollow,
  });
}
