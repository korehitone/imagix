// import 'dart:async';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:imagix/core/network/result_state.dart';
// import 'package:imagix/di/dependency_module.dart';
// import 'package:imagix/domain/post/model/post.dart';
// import 'package:imagix/domain/post/use_case/post_use_case.dart';
// import 'package:imagix/domain/profile/model/profile.dart';
// import 'package:imagix/domain/profile/use_case/profile_use_case.dart';
//
// enum SearchFilter { posts, profiles }
//
// class SearchState {
//   final String query;
//   final SearchFilter filter;
//   final List<Post> posts;
//   final List<Profile> profiles;
//   final String? errorMessage;
//
//   const SearchState({
//     this.query = '',
//     this.filter = SearchFilter.posts,
//     this.posts = const [],
//     this.profiles = const [],
//     this.errorMessage,
//   });
//
//   factory SearchState.empty() => const SearchState();
//
//   SearchState copyWith({
//     String? query,
//     SearchFilter? filter,
//     List<Post>? posts,
//     List<Profile>? profiles,
//     String? errorMessage,
//   }) {
//     return SearchState(
//       query: query ?? this.query,
//       filter: filter ?? this.filter,
//       posts: posts ?? this.posts,
//       profiles: profiles ?? this.profiles,
//       errorMessage: errorMessage,
//     );
//   }
// }
//
// class SearchViewModel extends AsyncNotifier<SearchState> {
//   PostUseCase get _postUseCase =>
//       ref.read(DependencyModule.postUseCaseProvider);
//
//   ProfileUseCase get _profileUseCase =>
//       ref.read(DependencyModule.profileUseCaseProvider);
//
//   static const int _limit = 20;
//
//   @override
//   FutureOr<SearchState> build() {
//     return SearchState.empty();
//   }
//
//   void setFilter(SearchFilter filter) {
//     final current = state.value ?? SearchState.empty();
//     state = AsyncData(current.copyWith(filter: filter));
//   }
//
//   void clearError() {
//     final current = state.value;
//     if (current == null) return;
//     state = AsyncData(current.copyWith(errorMessage: null));
//   }
//
//   Future<void> search(String rawQuery) async {
//     final query = rawQuery.trim();
//     final current = state.value ?? SearchState.empty();
//
//     if (query.isEmpty) {
//       state = AsyncData(
//         current.copyWith(
//           query: '',
//           posts: const [],
//           profiles: const [],
//           errorMessage: null,
//         ),
//       );
//       return;
//     }
//
//     state = AsyncData(current.copyWith(query: query, errorMessage: null));
//
//     switch (current.filter) {
//       case SearchFilter.posts:
//         final result = await _postUseCase.getPostsByQuery.invoke(query);
//         switch (result) {
//           case Success(data: final posts):
//             state = AsyncData(
//               (state.value ?? SearchState.empty()).copyWith(
//                 query: query,
//                 posts: posts,
//               ),
//             );
//             break;
//           case Error(error: final msg):
//             state = AsyncData(
//               (state.value ?? SearchState.empty()).copyWith(errorMessage: msg),
//             );
//             break;
//         }
//         break;
//
//       case SearchFilter.profiles:
//         final result = await _profileUseCase.getProfilesByQuery.invoke(query);
//         switch (result) {
//           case Success(data: final profiles):
//             state = AsyncData(
//               (state.value ?? SearchState.empty()).copyWith(
//                 query: query,
//                 profiles: profiles,
//               ),
//             );
//             break;
//           case Error(error: final msg):
//             state = AsyncData(
//               (state.value ?? SearchState.empty()).copyWith(errorMessage: msg),
//             );
//             break;
//         }
//         break;
//     }
//   }
// }
