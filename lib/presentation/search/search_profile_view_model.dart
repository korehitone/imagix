import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/use_case/profile_use_case.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';

class SearchProfileViewModel extends AsyncNotifier<PaginatedState<Profile>> {
  ProfileUseCase get _profileUseCase =>
      ref.read(DependencyModule.profileUseCaseProvider);

  static const int _limit = 20;
  String _currentQuery = '';

  @override
  FutureOr<PaginatedState<Profile>> build() {
    return PaginatedState<Profile>.empty();
  }

  Future<void> search(String rawQuery) async {
    final query = rawQuery.trim();
    _currentQuery = query;

    final current = state.value ?? PaginatedState<Profile>.empty();

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

    final result = await _profileUseCase.getProfilesByQuery.invoke(
      query,
      offset: 0,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final profiles):
        state = AsyncData(
          current.copyWith(
            items: profiles,
            isLoading: false,
            isLoadingMore: false,
            hasMore: profiles.length == _limit,
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
    final current = state.value ?? PaginatedState<Profile>.empty();

    if (_currentQuery.isEmpty ||
        current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final result = await _profileUseCase.getProfilesByQuery.invoke(
      _currentQuery,
      offset: current.items.length,
      limit: _limit,
    );

    switch (result) {
      case Success(data: final newProfiles):
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...newProfiles],
            isLoadingMore: false,
            hasMore: newProfiles.length == _limit,
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
    state = AsyncData(PaginatedState<Profile>.empty());
  }

  void clearError() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(errorMessage: null));
  }
}
