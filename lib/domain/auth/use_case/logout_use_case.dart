import 'package:imagix/domain/auth/repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> execute() async {
    await _repository.clearLocalUser();
    await _repository.logout();
  }
}
