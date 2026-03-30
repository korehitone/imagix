import 'package:imagix/domain/follow/repository/follow_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/follow.dart';

class GetFollowerUseCase {
  final FollowRepository _repository;

  const GetFollowerUseCase(this._repository);

  Future<ResultState<List<Follow>>> invoke(String userId) async =>
      _repository.getFollowers(userId);
}
