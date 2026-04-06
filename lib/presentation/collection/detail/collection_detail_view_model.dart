import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/domain/collection/use_case/collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/use_case/post_use_case.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';

class CollectionDetailViewModel
    extends AsyncNotifier<PaginatedState<CollectionItem>> {
  CollectionItemUseCase get _collectionItemUseCase =>
      ref.read(DependencyModule.collectionItemUseCaseProvider);

  CollectionUseCase get _collectionUseCase =>
      ref.read(DependencyModule.collectionUseCaseProvider);

  AuthUseCase get _authUseCase =>
      ref.read(DependencyModule.authUseCaseProvider);

  PostUseCase get _postUseCase =>
      ref.read(DependencyModule.postUseCaseProvider);

  static const int _limit = 20;
  String _collectionId = '';

  @override
  FutureOr<PaginatedState<CollectionItem>> build() {
    return PaginatedState<CollectionItem>.empty();
  }

  Future<void> init(String collectionId) async {
    _collectionId = collectionId;

    final current = state.value ?? PaginatedState<CollectionItem>.empty();
    if (current.items.isNotEmpty || current.isLoading) return;

    await refresh(collectionId);
  }

  Future<void> refresh(String collectionId) async {
    _collectionId = collectionId;

    final current = state.value ?? PaginatedState<CollectionItem>.empty();

    state = AsyncData(
      current.copyWith(
        isLoading: true,
        isLoadingMore: false,
        items: [],
        hasMore: true,
        errorMessage: null,
      ),
    );

    final result = await _collectionItemUseCase.getItems.invoke(
      collectionId,
      offset: 0,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final items):
        state = AsyncData(
          current.copyWith(
            items: items,
            isLoading: false,
            isLoadingMore: false,
            hasMore: items.length == _limit,
          ),
        );
        break;

      case Error(error: final msg):
        state = AsyncData(
          current.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: msg,
          ),
        );
        break;
    }
  }

  Future<void> loadMore() async {
    final current = state.value ?? PaginatedState<CollectionItem>.empty();

    if (_collectionId.isEmpty ||
        current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final result = await _collectionItemUseCase.getItems.invoke(
      _collectionId,
      offset: current.items.length,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final newItems):
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...newItems],
            isLoadingMore: false,
            hasMore: newItems.length == _limit,
          ),
        );
        break;

      case Error(error: final msg):
        state = AsyncData(
          current.copyWith(isLoadingMore: false, errorMessage: msg),
        );
        break;
    }
  }

  Future<Post?> getPostDetail(String postId) async {
    final result = await _postUseCase.getPost.invoke(postId);

    switch (result) {
      case Success(data: final post):
        return post;

      case Error(error: final msg):
        final current = state.value ?? PaginatedState<CollectionItem>.empty();
        state = AsyncData(current.copyWith(errorMessage: msg));
        return null;
    }
  }

  Future<void> removeItem(String collectionId, int itemId) async {
    final current = state.value ?? PaginatedState<CollectionItem>.empty();

    final previousItems = [...current.items];

    state = AsyncData(
      current.copyWith(
        items: current.items.where((item) => item.itemId != itemId).toList(),
      ),
    );

    final result = await _collectionItemUseCase.delete.invoke(itemId);

    switch (result) {
      case Success():
        await refresh(collectionId);

        final myId = _authUseCase.getCurrentUser.invoke()?.id;
        ref.invalidate(DependencyModule.profileViewModelProvider(null));
        if (myId != null) {
          ref.invalidate(DependencyModule.profileViewModelProvider(myId));
        }
        break;

      case Error(error: final msg):
        state = AsyncData(
          current.copyWith(items: previousItems, errorMessage: msg),
        );
        break;
    }
  }

  Future<bool> deleteCollection(String collectionId) async {
    final result = await _collectionUseCase.delete.invoke(collectionId);

    switch (result) {
      case Success():
        final myId = _authUseCase.getCurrentUser.invoke()?.id;

        ref.invalidate(DependencyModule.profileViewModelProvider(null));
        if (myId != null) {
          ref.invalidate(DependencyModule.profileViewModelProvider(myId));
        }

        return true;

      case Error(error: final msg):
        final current = state.value ?? PaginatedState<CollectionItem>.empty();
        state = AsyncData(current.copyWith(errorMessage: msg));
        return false;
    }
  }

  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(errorMessage: null));
  }
}

// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:imagix/core/network/result_state.dart';
// import 'package:imagix/di/dependency_module.dart';
// import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
// import 'package:imagix/domain/collection/model/collection_item.dart';
// import 'package:imagix/domain/collection/use_case/collection_item_use_case.dart';
// import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
// import 'package:imagix/domain/post/model/post.dart';
//
// class CollectionDetailViewModel extends AsyncNotifier<List<CollectionItem>> {
//   CollectionItemUseCase get _collectionItemUseCase =>
//       ref.read(DependencyModule.collectionItemUseCaseProvider);
//
//   CollectionUseCase get _collectionUseCase =>
//       ref.read(DependencyModule.collectionUseCaseProvider);
//
//   AuthUseCase get _authUseCase =>
//       ref.read(DependencyModule.authUseCaseProvider);
//
//   @override
//   FutureOr<List<CollectionItem>> build() async {
//     return <CollectionItem>[];
//   }
//
//   Future<void> init(String collectionId) async {
//     state = const AsyncLoading();
//     state = await AsyncValue.guard(() => _fetchItems(collectionId));
//   }
//
//   Future<List<CollectionItem>> _fetchItems(String collectionId) async {
//     final result = await _collectionItemUseCase.getItems.invoke(collectionId);
//
//     return switch (result) {
//       Success(data: final items) => items,
//       Error(error: final msg) => throw Exception(msg),
//     };
//   }
//
//   Future<void> refresh(String collectionId) async {
//     state = await AsyncValue.guard(() => _fetchItems(collectionId));
//   }
//
//   Future<void> removeItem(String collectionId, int itemId) async {
//     final currentItems = state.value;
//     if (currentItems == null) return;
//
//     final previousItems = [...currentItems];
//
//     state = AsyncData(
//       currentItems.where((item) => item.itemId != itemId).toList(),
//     );
//
//     final result = await _collectionItemUseCase.delete.invoke(itemId);
//
//     switch (result) {
//       case Success():
//         // ==========================================
//         // REFRESH DETAIL COLLECTION
//         // biar sinkron sama backend
//         // ==========================================
//         await refresh(collectionId);
//
//         // ==========================================
//         // REFRESH PROFILE COLLECTIONS
//         // biar total item di profile ikut update
//         // ==========================================
//         final myId = _authUseCase.getCurrentUser.invoke()?.id;
//         ref.invalidate(DependencyModule.profileViewModelProvider(null));
//         if (myId != null) {
//           ref.invalidate(DependencyModule.profileViewModelProvider(myId));
//         }
//         break;
//
//       case Error(error: final msg):
//         state = AsyncData(previousItems);
//         state = AsyncError(msg, StackTrace.current);
//         state = AsyncData(previousItems);
//         break;
//     }
//   }
//
//   Future<bool> deleteCollection(String collectionId) async {
//     final result = await _collectionUseCase.delete.invoke(collectionId);
//
//     switch (result) {
//       case Success():
//         final myId = _authUseCase.getCurrentUser.invoke()?.id;
//
//         // refresh profile collections
//         ref.invalidate(DependencyModule.profileViewModelProvider(null));
//         if (myId != null) {
//           ref.invalidate(DependencyModule.profileViewModelProvider(myId));
//         }
//
//         return true;
//
//       case Error(error: final msg):
//         state = AsyncError(msg, StackTrace.current);
//         return false;
//     }
//   }
//
//   Future<Post?> getPostDetail(String postId) async {
//     final result = await ref
//         .read(DependencyModule.postUseCaseProvider)
//         .getPost
//         .invoke(postId);
//
//     switch (result) {
//       case Success(data: final post):
//         return post;
//
//       case Error(error: final msg):
//         state = AsyncError(msg, StackTrace.current);
//         return null;
//     }
//   }
// }
