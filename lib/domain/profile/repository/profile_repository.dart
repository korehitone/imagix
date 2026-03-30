import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/model/profile_request.dart';

import '../../common/model/user_profile.dart';

abstract class ProfileRepository {
  Future<ResultState<Profile>> getProfile(String currentAuthId, String userId);
  Future<ResultState<UserProfile>> updateProfile(
    String userId,
    ProfileRequest request,
  );
}
