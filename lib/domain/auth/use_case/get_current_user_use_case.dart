import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);

  User? invoke() => _repository.getCurrentUser();
}
