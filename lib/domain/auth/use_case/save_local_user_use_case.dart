import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/common/model/user_profile.dart';

class SaveLocalUserUseCase {
  final AuthRepository _repository;
  SaveLocalUserUseCase(this._repository);

  Future<void> invoke(UserProfile user) => _repository.saveLocalUser(user);
}
