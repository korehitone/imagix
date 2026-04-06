import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/data/collection/repository/collection_item_repository_impl.dart';
import 'package:imagix/data/collection/repository/collection_repository_impl.dart';
import 'package:imagix/data/comment/repository/comment_repository_impl.dart';
import 'package:imagix/data/follow/repository/follow_repository_impl.dart';
import 'package:imagix/data/post/repository/post_repository_impl.dart';
import 'package:imagix/data/profile/repository/profile_repository_impl.dart';
import 'package:imagix/domain/auth/use_case/auth_use_case.dart';
import 'package:imagix/domain/auth/use_case/delete_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_current_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/get_local_user_use_case.dart';
import 'package:imagix/domain/auth/use_case/login_use_case.dart';
import 'package:imagix/domain/auth/use_case/logout_use_case.dart';
import 'package:imagix/domain/auth/use_case/register_use_case.dart';
import 'package:imagix/domain/auth/use_case/resend_verification_email_use_case.dart';
import 'package:imagix/domain/auth/use_case/restore_account_use_case.dart';
import 'package:imagix/domain/auth/use_case/save_local_user_use_case.dart';
import 'package:imagix/domain/collection/model/collection.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/domain/collection/repository/collection_item_repository.dart';
import 'package:imagix/domain/collection/repository/collection_repository.dart';
import 'package:imagix/domain/collection/use_case/collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/create_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/create_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_item_use_case.dart';
import 'package:imagix/domain/collection/use_case/delete_collection_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collection_items_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collection_with_saved_use_case.dart';
import 'package:imagix/domain/collection/use_case/get_collections_use_case.dart';
import 'package:imagix/domain/collection/use_case/update_collection_use_case.dart';
import 'package:imagix/domain/comment/repository/comment_repository.dart';
import 'package:imagix/domain/comment/use_case/create_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/delete_comment_use_case.dart';
import 'package:imagix/domain/comment/use_case/get_comments_use_case.dart';
import 'package:imagix/domain/comment/use_case/update_comment_use_case.dart';
import 'package:imagix/domain/follow/repository/follow_repository.dart';
import 'package:imagix/domain/follow/use_case/get_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/get_following_use_case.dart';
import 'package:imagix/domain/follow/use_case/remove_follower_use_case.dart';
import 'package:imagix/domain/follow/use_case/toggle_follow_use_case.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/repository/post_repository.dart';
import 'package:imagix/domain/post/use_case/create_post_use_case.dart';
import 'package:imagix/domain/post/use_case/delete_post_use_case.dart';
import 'package:imagix/domain/post/use_case/get_liked_posts_use_case.dart';
import 'package:imagix/domain/post/use_case/get_post_use_case.dart';
import 'package:imagix/domain/post/use_case/get_posts_by_query_use_case.dart';
import 'package:imagix/domain/post/use_case/get_posts_use_case.dart';
import 'package:imagix/domain/post/use_case/get_user_posts_use_case.dart';
import 'package:imagix/domain/post/use_case/toggle_like_use_case.dart';
import 'package:imagix/domain/post/use_case/update_post_use_case.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/repository/profile_repository.dart';
import 'package:imagix/domain/profile/use_case/get_profile_use_case.dart';
import 'package:imagix/domain/profile/use_case/get_profiles_by_query_use_case.dart';
import 'package:imagix/domain/profile/use_case/profile_use_case.dart';
import 'package:imagix/domain/profile/use_case/update_profile_use_case.dart';
import 'package:imagix/presentation/auth/viewmodel/auth_view_model.dart';
import 'package:imagix/presentation/auth/viewmodel/data/auth_data.dart';
import 'package:imagix/presentation/collection/detail/collection_detail_view_model.dart';
import 'package:imagix/presentation/collection/form/collection_form_view_model.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/like/liked_view_model.dart';
import 'package:imagix/presentation/post/detail/image_detail_data.dart';
import 'package:imagix/presentation/post/detail/image_detail_view_model.dart';
import 'package:imagix/presentation/post/upload/upload_view_model.dart';
import 'package:imagix/presentation/profile/edit/profile_edit_view_model.dart';
import 'package:imagix/presentation/profile/profile_collections_view_model.dart';
import 'package:imagix/presentation/profile/profile_data.dart';
import 'package:imagix/presentation/profile/profile_posts_view_model.dart';
import 'package:imagix/presentation/profile/profile_view_model.dart';
import 'package:imagix/presentation/search/search_post_view_model.dart';
import 'package:imagix/presentation/search/search_profile_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/local/global_preferences.dart';
import '../data/auth/repository/auth_repository_impl.dart';
import '../domain/auth/repository/auth_repository.dart';
import '../domain/comment/use_case/comment_use_case.dart';
import '../domain/follow/use_case/follow_use_case.dart';
import '../domain/post/use_case/post_use_case.dart';
import '../presentation/post/home/home_view_model.dart';

abstract class DependencyModule {
  static final supabaseProvider = Provider<SupabaseClient>(
    (ref) => Supabase.instance.client,
  );

  static final sharedPrefProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError(),
  );

  static final globalPrefProvider = Provider<GlobalPreferences>((ref) {
    final shared = ref.watch(sharedPrefProvider);
    return GlobalPreferences(shared);
  });

  // REPO
  static final authRepoProvider = Provider<AuthRepository>((ref) {
    return AuthRepositoryImpl(
      ref.watch(supabaseProvider),
      ref.watch(globalPrefProvider),
    );
  });

  static final collectionRepoProvider = Provider<CollectionRepository>((ref) {
    return CollectionRepositoryImpl(ref.watch(supabaseProvider));
  });

  static final collectionItemRepoProvider = Provider<CollectionItemRepository>((
    ref,
  ) {
    return CollectionItemRepositoryImpl(ref.watch(supabaseProvider));
  });

  static final commentRepoProvider = Provider<CommentRepository>((ref) {
    return CommentRepositoryImpl(ref.watch(supabaseProvider));
  });

  static final followRepoProvider = Provider<FollowRepository>((ref) {
    return FollowRepositoryImpl(ref.watch(supabaseProvider));
  });

  static final postRepoProvider = Provider<PostRepository>((ref) {
    return PostRepositoryImpl(ref.watch(supabaseProvider));
  });

  static final profileRepoProvider = Provider<ProfileRepository>((ref) {
    return ProfileRepositoryImpl(ref.watch(supabaseProvider));
  });

  //   USE CASE
  static final authUseCaseProvider = Provider<AuthUseCase>((ref) {
    final repo = ref.watch(authRepoProvider);
    return AuthUseCase(
      login: LoginUseCase(repo),
      register: RegisterUseCase(repo),
      getCurrentUser: GetCurrentUserUseCase(repo),
      saveLocalUser: SaveLocalUserUseCase(repo),
      logout: LogoutUseCase(repo),
      deleteAccount: DeleteAccountUseCase(repo),
      restoreAccount: RestoreAccountUseCase(repo),
      getLocalUser: GetLocalUserUseCase(repo),
      resendVerificationEmail: ResendVerificationEmailUseCase(repo),
    );
  });

  static final collectionUseCaseProvider = Provider<CollectionUseCase>((ref) {
    final collectionRepo = ref.watch(collectionRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return CollectionUseCase(
      getCollections: GetCollectionsUseCase(collectionRepo, authRepo),
      getCollectionWithSaved: GetCollectionWithSavedUseCase(
        collectionRepo,
        authRepo,
      ),
      create: CreateCollectionUseCase(collectionRepo, authRepo),
      update: UpdateCollectionUseCase(collectionRepo, authRepo),
      delete: DeleteCollectionUseCase(collectionRepo, authRepo),
    );
  });

  static final collectionItemUseCaseProvider = Provider<CollectionItemUseCase>((
    ref,
  ) {
    final collectionItemRepo = ref.watch(collectionItemRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return CollectionItemUseCase(
      getItems: GetCollectionItemsUseCase(collectionItemRepo, authRepo),
      create: CreateCollectionItemUseCase(collectionItemRepo, authRepo),
      delete: DeleteCollectionItemUseCase(collectionItemRepo, authRepo),
    );
  });

  static final commentUseCaseProvider = Provider<CommentUseCase>((ref) {
    final commentRepo = ref.watch(commentRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return CommentUseCase(
      getComments: GetCommentsUseCase(commentRepo, authRepo),
      create: CreateCommentUseCase(commentRepo, authRepo),
      update: UpdateCommentUseCase(commentRepo, authRepo),
      delete: DeleteCommentUseCase(commentRepo, authRepo),
    );
  });

  static final followUseCaseProvider = Provider<FollowUseCase>((ref) {
    final followRepo = ref.watch(followRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return FollowUseCase(
      getFollower: GetFollowerUseCase(followRepo),
      getFollowing: GetFollowingUseCase(followRepo),
      removeFollower: RemoveFollowerUseCase(followRepo, authRepo),
      toggleFollow: ToggleFollowUseCase(followRepo, authRepo),
    );
  });

  static final postUseCaseProvider = Provider<PostUseCase>((ref) {
    final postRepo = ref.watch(postRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return PostUseCase(
      getPosts: GetPostsUseCase(postRepo),
      getPost: GetPostUseCase(postRepo, authRepo),
      getLikedPosts: GetLikedPostsUseCase(postRepo, authRepo),
      getPostsByQuery: GetPostsByQueryUseCase(postRepo),
      getUserPosts: GetUserPostsUseCase(postRepo),
      create: CreatePostUseCase(postRepo, authRepo),
      update: UpdatePostUseCase(postRepo, authRepo),
      delete: DeletePostUseCase(postRepo, authRepo),
      toggleLike: ToggleLikeUseCase(postRepo, authRepo),
    );
  });

  static final profileUseCaseProvider = Provider<ProfileUseCase>((ref) {
    final profileRepo = ref.watch(profileRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    return ProfileUseCase(
      getProfilesByQuery: GetProfilesByQueryUseCase(profileRepo),
      getProfile: GetProfileUseCase(profileRepo, authRepo),
      updateProfile: UpdateProfileUseCase(profileRepo, authRepo),
    );
  });

  static final authViewModelProvider =
      AsyncNotifierProvider<AuthViewModel, AuthData>(() => AuthViewModel());

  static final homeViewModelProvider =
      AsyncNotifierProvider<HomeViewModel, PaginatedState<Post>>(
        () => HomeViewModel(),
      );

  static final imageDetailViewModelProvider =
      AsyncNotifierProvider.family<
        ImageDetailViewModel,
        ImageDetailData,
        String
      >((id) => ImageDetailViewModel());

  // static final profileViewModelProvider =
  //     AsyncNotifierProvider<ProfileViewModel, ProfileData>(
  //       () => ProfileViewModel(),
  //     );

  static final profileViewModelProvider =
      AsyncNotifierProvider.family<ProfileViewModel, ProfileData, String?>(
        (id) => ProfileViewModel(),
      );

  static final uploadViewModelProvider =
      AsyncNotifierProvider<UploadViewModel, Post?>(() => UploadViewModel());

  static final collectionDetailViewModelProvider =
      AsyncNotifierProvider.family<
        CollectionDetailViewModel,
        PaginatedState<CollectionItem>,
        String
      >((collectionId) => CollectionDetailViewModel());

  static final collectionFormViewModelProvider =
      AsyncNotifierProvider<CollectionFormViewModel, bool>(
        () => CollectionFormViewModel(),
      );

  static final profileFormViewModelProvider =
      AsyncNotifierProvider<ProfileEditViewModel, bool>(
        () => ProfileEditViewModel(),
      );

  static final likedViewModelProvider =
      AsyncNotifierProvider<LikedViewModel, PaginatedState<Post>>(
        () => LikedViewModel(),
      );

  // static final searchViewModelProvider =
  //     AsyncNotifierProvider<SearchViewModel, SearchState>(
  //       () => SearchViewModel(),
  //     );

  static final searchPostViewModelProvider =
      AsyncNotifierProvider<SearchPostViewModel, PaginatedState<Post>>(
        () => SearchPostViewModel(),
      );

  static final searchProfileViewModelProvider =
      AsyncNotifierProvider<SearchProfileViewModel, PaginatedState<Profile>>(
        () => SearchProfileViewModel(),
      );

  static final profilePostViewModelProvider =
      AsyncNotifierProvider.family<
        ProfilePostsViewModel,
        PaginatedState<Post>,
        String
      >((userId) => ProfilePostsViewModel());

  static final profileCollectionsViewModelProvider =
      AsyncNotifierProvider<
        ProfileCollectionsViewModel,
        PaginatedState<Collection>
      >(() => ProfileCollectionsViewModel());
}
