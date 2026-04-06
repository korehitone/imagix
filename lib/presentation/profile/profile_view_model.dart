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
    return ProfileData.empty();
  }

  Future<void> init(String? targetUserId) async {
    final myId = _authUseCase.getCurrentUser.invoke()?.id;
    final idToFetch = targetUserId ?? myId;
    if (idToFetch == null) return;

    if (state.value == null || state.value?.profile?.id != idToFetch) {
      state = const AsyncLoading();
    }

    final isOwn = (idToFetch == myId);

    if (isOwn && (state.value == null || state.value?.profile == null)) {
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
          (current) => current.copyWith(profile: p, isSuccess: true),
        );
        break;

      case Error(error: final msg):
        state = AsyncError(msg, StackTrace.current);
        break;
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

// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:imagix/core/network/result_state.dart';
// import 'package:imagix/di/dependency_module.dart';
// import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
// import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
// import 'package:imagix/domain/follow/use_case/follow_use_case.dart';
// import 'package:imagix/domain/post/use_case/post_use_case.dart';
// import 'package:imagix/domain/profile/use_case/profile_use_case.dart';
// import 'package:imagix/presentation/profile/profile_data.dart';
//
// class ProfileViewModel extends AsyncNotifier<ProfileData> {
//   AuthUseCase get _authUseCase =>
//       ref.read(DependencyModule.authUseCaseProvider);
//
//   CollectionUseCase get _collectionUseCase =>
//       ref.read(DependencyModule.collectionUseCaseProvider);
//
//   PostUseCase get _postUseCase =>
//       ref.read(DependencyModule.postUseCaseProvider);
//
//   FollowUseCase get _followUseCase =>
//       ref.read(DependencyModule.followUseCaseProvider);
//
//   ProfileUseCase get _profileUseCase =>
//       ref.read(DependencyModule.profileUseCaseProvider);
//
//   static const int _limit = 20;
//
//   @override
//   Future<ProfileData> build() async {
//     return ProfileData.empty();
//   }
//
//   Future<void> init(String? targetUserId) async {
//     final myId = _authUseCase.getCurrentUser.invoke()?.id;
//     final idToFetch = targetUserId ?? myId;
//     if (idToFetch == null) return;
//
//     // LOGIC: Kalau datanya kosong (abis invalidate) atau ID-nya ganti, PAKSA LOADING
//     if (state.value == null || state.value?.profile?.id != idToFetch) {
//       state = const AsyncLoading();
//     }
//
//     final isOwn = (idToFetch == myId);
//
//     // Ambil data lokal dulu buat profile sendiri biar instan
//     if (isOwn && (state.value == null || state.value?.profile == null)) {
//       final local = _authUseCase.getLocalUser.invoke()?.toDomain();
//       if (local != null) state = AsyncData(ProfileData(profile: local));
//     }
//
//     // Tarik data remote secara paralel
//     await Future.wait([
//       fetchRemoteProfile(idToFetch, isOwn),
//       fetchUserPosts(idToFetch),
//       if (isOwn) fetchUserCollections(),
//     ]);
//   }
//
//   Future<void> _silentRefresh(String idToFetch) async {
//     final isOwn = (idToFetch == _authUseCase.getCurrentUser.invoke()?.id);
//     await Future.wait([
//       fetchRemoteProfile(idToFetch, isOwn),
//       fetchUserPosts(idToFetch),
//       if (isOwn) fetchUserCollections(),
//     ]);
//   }
//
//   void _updateState(ProfileData Function(ProfileData current) update) {
//     final current = state.value ?? ProfileData.empty();
//     state = AsyncData(update(current));
//   }
//
//   void _syncLocalProfile(dynamic p) {
//     final localProfile = _authUseCase.getLocalUser.invoke();
//     if (localProfile != null) {
//       _authUseCase.saveLocalUser.invoke(
//         localProfile.copyWith(
//           id: p.id,
//           username: p.username,
//           bio: p.bio,
//           photo: p.photo,
//           totalPosts: p.totalPosts,
//           totalFollowers: p.totalFollowers,
//           totalFollowings: p.totalFollowings,
//           totalCollections: p.totalCollections,
//         ),
//       );
//     }
//   }
//
//   void clearError() {
//     _updateState((current) => current.copyWith(errorMessage: null));
//   }
//
//   Future<void> fetchRemoteProfile(String userId, bool isOwn) async {
//     final result = await _profileUseCase.getProfile.invoke(userId);
//
//     switch (result) {
//       case Success(data: final p):
//         if (isOwn) {
//           _syncLocalProfile(p);
//         }
//         _updateState(
//           (current) => current.copyWith(profile: p, isSuccess: true),
//         );
//         break;
//       case Error(error: final msg):
//         state = AsyncError(msg, StackTrace.current);
//     }
//   }
//
//   Future<void> fetchUserPosts(String userId) async {
//     final result = await _postUseCase.getUserPosts.invoke(userId);
//
//     switch (result) {
//       case Success(data: final posts):
//         // _updateState((current) => current.copyWith(posts: posts));
//         state = AsyncData(
//           (state.value ?? ProfileData.empty()).copyWith(posts: posts),
//         );
//         break;
//
//       case Error(error: final msg):
//         _updateState(
//           (current) => current.copyWith(
//             errorMessage: msg, // <--- SIMPEN ERRORNYA DI SINI
//           ),
//         );
//         break;
//     }
//   }
//
//   Future<void> fetchUserCollections() async {
//     final result = await _collectionUseCase.getCollections.invoke();
//     switch (result) {
//       case Success(data: final collections):
//         _updateState((current) => current.copyWith(collections: collections));
//         break;
//
//       case Error(error: final msg):
//         _updateState(
//           (current) => current.copyWith(
//             errorMessage: msg, // <--- SIMPEN ERRORNYA DI SINI
//           ),
//         );
//         break;
//     }
//   }
//
//   // follow
//
//   Future<void> fetchFollowers(String userId) async {
//     final result = await _followUseCase.getFollower.invoke(userId);
//     switch (result) {
//       case Success(data: final list):
//         _updateState((current) => current.copyWith(followers: list));
//         break;
//       case Error(error: final msg):
//         _updateState((current) => current.copyWith(errorMessage: msg));
//         break;
//     }
//   }
//
//   Future<void> fetchFollowing(String userId) async {
//     final result = await _followUseCase.getFollowing.invoke(userId);
//     switch (result) {
//       case Success(data: final list):
//         _updateState((current) => current.copyWith(followings: list));
//         break;
//       case Error(error: final msg):
//         _updateState((current) => current.copyWith(errorMessage: msg));
//         break;
//     }
//   }
//
//   // OPTIMISTIC TOGGLE FOLLOW (Di Profile Page Utama)
//   // Future<void> toggleFollowProfile(String targetUserId) async {
//   //   final currentData = state.value;
//   //   if (currentData == null || currentData.profile == null) return;
//   //
//   //   final isFollowingNow =
//   //       currentData.profile!.isFollowing; // Asumsi ada field ini
//   //
//   //   // 1. Update UI Langsung (Optimistic)
//   //   _updateState(
//   //     (current) => current.copyWith(
//   //       profile: current.profile?.copyWith(
//   //         isFollowing: !isFollowingNow,
//   //         totalFollowers: isFollowingNow
//   //             ? current.profile!.totalFollowers - 1
//   //             : current.profile!.totalFollowers + 1,
//   //       ),
//   //     ),
//   //   );
//   //
//   //   // 2. Tembak API
//   //   final result = await _followUseCase.toggleFollow.invoke(targetUserId);
//   //
//   //   // 3. Kalau Gagal, Balikin State (Rollback)
//   //   if (result is Error) {
//   //     state = AsyncData(currentData);
//   //
//   //     // Ambil pesannya dari property 'error' milik ResultState.Error
//   //     final errorMsg = (result as Error).error;
//   //     _updateState((current) => current.copyWith(errorMessage: errorMsg));
//   //   }
//   // }
//
//   Future<void> toggleFollowProfile(String targetUserId) async {
//     final previousData = state.value;
//     if (previousData == null) return;
//
//     final isMainProfile = previousData.profile?.id == targetUserId;
//
//     // LOGIKA BARU: Lebih aman & Gak Merah
//     bool wasFollowing;
//
//     if (isMainProfile) {
//       // Kalau yang di-klik itu profile di Header
//       wasFollowing = previousData.profile?.isFollowing ?? false;
//     } else {
//       // Kalau yang di-klik itu user di dalam list overlay
//
//       // Cek ulang apakah beneran ketemu atau cuma fallback
//       if (previousData.followings.any((f) => f.userId == targetUserId)) {
//         wasFollowing = previousData.followings
//             .firstWhere((f) => f.userId == targetUserId)
//             .isFollowing;
//       } else {
//         wasFollowing = false;
//       }
//     }
//
//     // ==========================================
//     // 2. OPTIMISTIC UPDATE (Tetap Sama)
//     // ==========================================
//     _updateState((current) {
//       final updatedProfile = isMainProfile
//           ? current.profile?.copyWith(
//               isFollowing: !wasFollowing,
//               totalFollowers: wasFollowing
//                   ? current.profile!.totalFollowers - 1
//                   : current.profile!.totalFollowers + 1,
//             )
//           : current.profile;
//
//       final updatedFollowings = current.followings.map((f) {
//         if (f.userId == targetUserId) {
//           return f.copyWith(isFollowing: !wasFollowing);
//         }
//         return f;
//       }).toList();
//
//       return current.copyWith(
//         profile: updatedProfile,
//         followings: updatedFollowings,
//       );
//     });
//
//     // 3. Tembak API
//     final result = await _followUseCase.toggleFollow.invoke(targetUserId);
//
//     // 4. Rollback kalau gagal
//     if (result is Error) {
//       state = AsyncData(previousData);
//       _updateState(
//         (current) => current.copyWith(errorMessage: (result as Error).error),
//       );
//     }
//   }
//
//   // OPTIMISTIC REMOVE FOLLOWER (Di List Followers)
//   Future<void> removeFollower(String followerId) async {
//     final previousData = state.value;
//     if (previousData == null) return;
//
//     // 1. Optimistic: Hapus dari list & kurangi counter
//     _updateState(
//       (current) => current.copyWith(
//         followers: current.followers
//             .where((f) => f.userId != followerId)
//             .toList(),
//         profile: current.profile?.copyWith(
//           totalFollowers: current.profile!.totalFollowers - 1,
//         ),
//       ),
//     );
//
//     final result = await _followUseCase.removeFollower.invoke(followerId);
//
//     if (result is Error) {
//       state = AsyncData(previousData);
//
//       // Ambil pesannya dari property 'error' milik ResultState.Error
//       final errorMsg = (result as Error).error;
//       _updateState((current) => current.copyWith(errorMessage: errorMsg));
//     }
//   }
//
//   void resetSuccess() {
//     final currentData = state.value;
//     if (currentData != null) {
//       state = AsyncData(currentData.copyWith(isSuccess: false));
//     }
//   }
// }
