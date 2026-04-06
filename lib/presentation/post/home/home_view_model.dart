import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/use_case/post_use_case.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';

class HomeViewModel extends AsyncNotifier<PaginatedState<Post>> {
  PostUseCase get _postUseCase =>
      ref.read(DependencyModule.postUseCaseProvider);

  static const int _limit = 20;

  @override
  FutureOr<PaginatedState<Post>> build() {
    return PaginatedState<Post>.empty();
  }

  Future<void> init() async {
    final current = state.value ?? PaginatedState<Post>.empty();
    if (current.items.isNotEmpty || current.isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    final current = state.value ?? PaginatedState<Post>.empty();

    state = AsyncData(
      current.copyWith(
        isLoading: true,
        isLoadingMore: false,
        items: [],
        hasMore: true,
        errorMessage: null,
      ),
    );

    final result = await _postUseCase.getPosts.invoke(offset: 0, limit: _limit);

    switch (result) {
      case Success(data: final posts):
        state = AsyncData(
          current.copyWith(
            items: posts,
            isLoading: false,
            isLoadingMore: false,
            hasMore: posts.length == _limit,
            errorMessage: null,
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
    final current = state.value ?? PaginatedState<Post>.empty();

    if (current.isLoading || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(
      current.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final result = await _postUseCase.getPosts.invoke(
      offset: current.items.length,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final newPosts):
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...newPosts],
            isLoadingMore: false,
            hasMore: newPosts.length == _limit,
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
// import 'package:imagix/domain/post/model/post.dart';
// import 'package:imagix/domain/post/use_case/post_use_case.dart';
// import 'package:imagix/presentation/common/pagination/paginated_state.dart';
//
// class HomeViewModel extends AsyncNotifier<PaginatedState<Post>> {
//   PostUseCase get _postUseCase =>
//       ref.read(DependencyModule.postUseCaseProvider);
//
//   static const int _limit = 20;
//
//   @override
//   FutureOr<PaginatedState<Post>> build() {
//     return _fetchPosts();
//   }
//
//   Future<List<Post>> _fetchPosts() async {
//     final result = await _postUseCase.getPosts.invoke();
//     return switch (result) {
//       Success(data: final posts) => posts,
//       Error(error: final msg) => throw Exception(msg),
//     };
//   }
//
//   Future<void> getPosts() async {
//     state = await AsyncValue.guard(() => _fetchPosts());
//   }
// }
