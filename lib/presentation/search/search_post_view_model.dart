import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/use_case/post_use_case.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';

class SearchPostViewModel extends AsyncNotifier<PaginatedState<Post>> {
  PostUseCase get _postUseCase =>
      ref.read(DependencyModule.postUseCaseProvider);

  static const int _limit = 20;
  String _currentQuery = '';

  @override
  FutureOr<PaginatedState<Post>> build() {
    return PaginatedState<Post>.empty();
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    _currentQuery = query;

    final current = state.value ?? PaginatedState<Post>.empty();

    if (query.isEmpty) {
      state = AsyncData(
        current.copyWith(
          items: [],
          isLoading: false,
          isLoadingMore: false,
          hasMore: true,
          errorMessage: null,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        isLoading: true,
        isLoadingMore: false,
        items: [],
        hasMore: true,
        errorMessage: null,
      ),
    );

    final result = await _postUseCase.getPostsByQuery.invoke(
      query,
      offset: 0,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final posts):
        state = AsyncData(
          current.copyWith(
            items: posts,
            isLoading: false,
            isLoadingMore: false,
            hasMore: posts.length == _limit,
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

    if (_currentQuery.isEmpty ||
        current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final result = await _postUseCase.getPostsByQuery.invoke(
      _currentQuery,
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

  void clear() {
    _currentQuery = '';
    state = AsyncData(PaginatedState<Post>.empty());
  }

  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(errorMessage: null));
  }
}
