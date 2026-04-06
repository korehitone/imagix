import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/profile/model/profile_request.dart';
import 'package:imagix/domain/profile/use_case/profile_use_case.dart';

class ProfileEditViewModel extends AsyncNotifier<bool> {
  ProfileUseCase get _profileUseCase =>
      ref.read(DependencyModule.profileUseCaseProvider);

  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> updateProfile({
    required String username,
    required String bio,
    File? photo,
  }) async {
    state = const AsyncLoading();

    final result = await _profileUseCase.updateProfile.invoke(
      ProfileRequest(username: username, bio: bio, photo: photo),
    );

    switch (result) {
      case Success():
        final myId = _authUseCase.getCurrentUser.invoke()?.id;

        // ref.invalidate(DependencyModule.profileViewModelProvider(null));
        // if (myId != null) {
        //   ref.invalidate(DependencyModule.profileViewModelProvider(myId));
        // }

        await ref
            .read(DependencyModule.profileViewModelProvider(null).notifier)
            .init(null);

        if (myId != null) {
          await ref
              .read(DependencyModule.profileViewModelProvider(myId).notifier)
              .init(myId);
        }

        state = const AsyncData(true);
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
    }
  }
}
