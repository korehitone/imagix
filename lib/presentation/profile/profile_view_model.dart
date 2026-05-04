import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/follow/use_case/follow_use_case.dart';
import 'package:imagix/domain/profile/use_case/profile_use_case.dart';
import 'package:imagix/presentation/profile/profile_data.dart';

class ProfileViewModel extends AsyncNotifier<ProfileData> {
  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  FollowUseCase get _followUseCase =>
      ref.read(DependencyModule.followUseCaseProvider);

  ProfileUseCase get _profileUseCase =>
      ref.read(DependencyModule.profileUseCaseProvider);

  @override
  Future<ProfileData> build() async {
    final local = _authUseCase.getLocalUser.invoke()?.toDomain();
    if (local != null) {
      return ProfileData(profile: local); // own profile → instant
    }
    return ProfileData.empty();
  }

  Future<void> init(String? targetUserId) async {
    final myId = _authUseCase.getCurrentUser.invoke()?.id;
    final idToFetch = targetUserId ?? myId;
    if (idToFetch == null) return;

    // if (state.value == null || state.value?.profile?.id != idToFetch) {
    //   state = const AsyncLoading();
    // }
    //
    final isOwn = (idToFetch == myId);
    //
    // if (isOwn && (state.value == null || state.value?.profile == null)) {
    //   final local = _authUseCase.getLocalUser.invoke()?.toDomain();
    //   if (local != null) {
    //     state = AsyncData(ProfileData(profile: local));
    //   }
    // }

    // Hanya force loading kalau profile ID beda (pindah user)
    // if (state.value?.profile?.id != null &&
    //     state.value?.profile?.id != idToFetch) {
    //   state = const AsyncLoading();
    // }
    //
    // if (isOwn && state.value?.profile == null) {
    //   final local = _authUseCase.getLocalUser.invoke()?.toDomain();
    //   if (local != null) {
    //     state = AsyncData(ProfileData(profile: local));
    //   }
    // }
    if (state.value?.profile?.id != idToFetch) {
      state = const AsyncLoading();
    }

    if (isOwn) {
      // Profile sendiri: instant dari local
      final local = _authUseCase.getLocalUser.invoke()?.toDomain();
      if (local != null) {
        state = AsyncData(ProfileData(profile: local));
      }
    }

    await fetchRemoteProfile(idToFetch, isOwn);
  }

  Future<void> refresh(String? targetUserId) async {
    final myId = _authUseCase.getCurrentUser.invoke()?.id;
    final idToFetch = targetUserId ?? myId;
    if (idToFetch == null) return;

    state = const AsyncLoading(); // Show loading indicator

    final isOwn = (idToFetch == myId);

    if (isOwn) {
      final local = _authUseCase.getLocalUser.invoke()?.toDomain();
      if (local != null) {
        state = AsyncData(ProfileData(profile: local));
      }
    }

    await fetchRemoteProfile(idToFetch, isOwn);
  }

  Future<void> _silentRefresh(String idToFetch) async {
    final isOwn = (idToFetch == _authUseCase.getCurrentUser.invoke()?.id);
    await fetchRemoteProfile(idToFetch, isOwn);
  }

  void _updateState(ProfileData Function(ProfileData current) update) {
    final current = state.value ?? ProfileData.empty();
    state = AsyncData(update(current));
  }

  void _syncLocalProfile(dynamic p) {
    final localProfile = _authUseCase.getLocalUser.invoke();
    if (localProfile != null) {
      _authUseCase.saveLocalUser.invoke(
        localProfile.copyWith(
          id: p.id,
          username: p.username,
          bio: p.bio,
          photo: p.photo,
          totalPosts: p.totalPosts,
          totalFollowers: p.totalFollowers,
          totalFollowings: p.totalFollowings,
          totalCollections: p.totalCollections,
        ),
      );
    }
  }

  void clearError() {
    _updateState((current) => current.copyWith(errorMessage: null));
  }

  Future<void> fetchRemoteProfile(String userId, bool isOwn) async {
    final result = await _profileUseCase.getProfile.invoke(userId);

    switch (result) {
      case Success(data: final p):
        if (isOwn) {
          _syncLocalProfile(p);
        }
        _updateState(
          (current) =>
              current.copyWith(profile: p, isSuccess: true, errorMessage: null),
        );
        break;

      case Error(error: final msg):
        // ✅ CRITICAL: Kalau gagal & bukan profile sendiri → FULL ERROR!
        if (!isOwn ||
            state.value?.profile?.id !=
                _authUseCase.getCurrentUser.invoke()?.id) {
          state = AsyncError(msg, StackTrace.current);
        } else {
          // Profile sendiri gagal remote → tetep pake cache local
          _updateState((current) => current.copyWith(errorMessage: msg));
        }
        break;

      // case Error(error: final msg):
      //   if (state.value?.profile == null) {
      //     state = AsyncError(msg, StackTrace.current);
      //   } else {
      //     _updateState((current) => current.copyWith(errorMessage: msg));
      //   }
      //   break;
    }
  }

  Future<void> fetchFollowers(String userId) async {
    final result = await _followUseCase.getFollower.invoke(userId);

    switch (result) {
      case Success(data: final list):
        _updateState((current) => current.copyWith(followers: list));
        break;

      case Error(error: final msg):
        _updateState((current) => current.copyWith(errorMessage: msg));
        break;
    }
  }

  Future<void> fetchFollowing(String userId) async {
    final result = await _followUseCase.getFollowing.invoke(userId);

    switch (result) {
      case Success(data: final list):
        _updateState((current) => current.copyWith(followings: list));
        break;

      case Error(error: final msg):
        _updateState((current) => current.copyWith(errorMessage: msg));
        break;
    }
  }

  Future<void> toggleFollowProfile(String targetUserId) async {
    final previousData = state.value;
    if (previousData == null) return;

    final isMainProfile = previousData.profile?.id == targetUserId;

    bool wasFollowing;

    if (isMainProfile) {
      wasFollowing = previousData.profile?.isFollowing ?? false;
    } else {
      if (previousData.followings.any((f) => f.userId == targetUserId)) {
        wasFollowing = previousData.followings
            .firstWhere((f) => f.userId == targetUserId)
            .isFollowing;
      } else {
        wasFollowing = false;
      }
    }

    _updateState((current) {
      final updatedProfile = isMainProfile
          ? current.profile?.copyWith(
              isFollowing: !wasFollowing,
              totalFollowers: wasFollowing
                  ? current.profile!.totalFollowers - 1
                  : current.profile!.totalFollowers + 1,
            )
          : current.profile;

      final updatedFollowings = current.followings.map((f) {
        if (f.userId == targetUserId) {
          return f.copyWith(isFollowing: !wasFollowing);
        }
        return f;
      }).toList();

      return current.copyWith(
        profile: updatedProfile,
        followings: updatedFollowings,
      );
    });

    final result = await _followUseCase.toggleFollow.invoke(targetUserId);

    if (result is Error) {
      state = AsyncData(previousData);
      _updateState(
        (current) => current.copyWith(errorMessage: (result as Error).error),
      );
    } else {
      final currentProfileId = state.value?.profile?.id;
      if (currentProfileId != null) {
        unawaited(_silentRefresh(currentProfileId));
      }
    }
  }

  Future<void> removeFollower(String followerId) async {
    final previousData = state.value;
    if (previousData == null) return;

    _updateState(
      (current) => current.copyWith(
        followers: current.followers
            .where((f) => f.userId != followerId)
            .toList(),
        profile: current.profile?.copyWith(
          totalFollowers: current.profile!.totalFollowers - 1,
        ),
      ),
    );

    final result = await _followUseCase.removeFollower.invoke(followerId);

    if (result is Error) {
      state = AsyncData(previousData);
      final errorMsg = (result as Error).error;
      _updateState((current) => current.copyWith(errorMessage: errorMsg));
    } else {
      final currentProfileId = state.value?.profile?.id;
      if (currentProfileId != null) {
        unawaited(_silentRefresh(currentProfileId));
      }
    }
  }

  void resetSuccess() {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncData(currentData.copyWith(isSuccess: false));
    }
  }
}
