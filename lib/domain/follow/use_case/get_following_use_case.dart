import 'package:imagix/domain/follow/repository/follow_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/follow.dart';

class GetFollowingUseCase {
  final FollowRepository _repository;

  const GetFollowingUseCase(this._repository);

  Future<ResultState<List<Follow>>> invoke(String userId) async =>
      _repository.getFollowing(userId);
}
