import 'package:imagix/domain/auth/repository/auth_repository.dart';

import '../../common/model/user_profile.dart';

class GetLocalUserUseCase {
  final AuthRepository _repository;

  const GetLocalUserUseCase(this._repository);

  UserProfile? invoke() => _repository.getLocalUser();
}
