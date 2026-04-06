import 'package:imagix/domain/profile/repository/profile_repository.dart';

import '../../../core/network/result_state.dart';
import '../model/profile.dart';

class GetProfilesByQueryUseCase {
  final ProfileRepository _repository;

  const GetProfilesByQueryUseCase(this._repository);

  Future<ResultState<List<Profile>>> invoke(
    String query, {
    required int offset,
    required int limit,
  }) async =>
      _repository.getProfilesByQuery(query, offset: offset, limit: limit);
}
