import 'package:imagix/core/error/exception_handler.dart';
import 'package:imagix/core/mapper/supabase_mapper.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/profile/model/view/profile_view_response.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Stream<ResultState<Profile>> getProfile(String userId) async* {
    yield const Loading();
    try {
      final response = await _client
          .from('profile_view')
          .select()
          .eq('id', userId)
          .single();

      final profile = response
          .decodeSingle(ProfileViewResponse.fromJson)
          ?.toDomain();
      if (profile == null) {
        yield Error(ExceptionHandler.handle("Profile not found"));
      } else {
        yield Success(profile);
      }
    } catch (e) {
      final error = ExceptionHandler.handle(e);
      yield Error(error);
    }
  }
}
