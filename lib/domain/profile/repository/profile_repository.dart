import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/profile/model/profile.dart';

abstract class ProfileRepository {
  Stream<ResultState<Profile>> getProfile(String userId);
}
