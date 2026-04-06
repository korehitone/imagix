import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/presentation/auth/screen/resend_email_page.dart';
import 'package:imagix/presentation/auth/screen/restore_account_page.dart';
import 'package:imagix/presentation/collection/detail/collections_page.dart';
import 'package:imagix/presentation/collection/form/create_collection_page.dart';
import 'package:imagix/presentation/common/main_screen.dart';
import 'package:imagix/presentation/like/liked_page.dart';
import 'package:imagix/presentation/post/detail/image_details_page.dart';
import 'package:imagix/presentation/post/home/home_page.dart';
import 'package:imagix/presentation/post/upload/upload_post_page.dart';
import 'package:imagix/presentation/profile/edit/edit_profile_page.dart';
import 'package:imagix/presentation/profile/profile_page.dart';
import 'package:imagix/presentation/search/search_page.dart';

import '../../di/dependency_module.dart';
import '../../presentation/auth/screen/login_page.dart';
import '../../presentation/auth/screen/signup_page.dart';

class AppRoute {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const search = "/search";
  static const profile = "/profile/:userId";
  static const menuProfile = "/profile";
  static const editProfile = "/edit-profile";
  static const liked = "/liked";
  static const createPost = "/upload-post";
  static const createCollection = "/upload-collection";
  static const collectionDetail = "/collection-detail";
  static const imageDetail = "/image-detail";
  static const restoreAccount = '/restore-account';
  static const resendEmail = '/resend-email';

  static String profileWithId(String id) => "/profile/$id";
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.login,
    redirect: (context, state) {
      final authState = ref.watch(DependencyModule.authViewModelProvider);
      final authData = authState.value;

      final bool hasSession = authData?.user != null;
      final bool isDeletedAccount = authData?.isDeletedAccount == true;

      final bool isPublicRoute =
          state.matchedLocation == AppRoute.login ||
          state.matchedLocation == AppRoute.signup ||
          state.matchedLocation == AppRoute.restoreAccount ||
          state.matchedLocation == AppRoute.resendEmail;

      if (isDeletedAccount &&
          state.matchedLocation != AppRoute.restoreAccount) {
        return AppRoute.restoreAccount;
      }

      if (hasSession &&
          !isDeletedAccount &&
          (state.matchedLocation == AppRoute.login ||
              state.matchedLocation == AppRoute.signup ||
              state.matchedLocation == AppRoute.restoreAccount)) {
        return AppRoute.home;
      }

      if (!hasSession && !isDeletedAccount && !isPublicRoute) {
        return AppRoute.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home
          StatefulShellBranch(
            routes: [
              GoRoute(path: AppRoute.home, builder: (_, _) => const HomePage()),
            ],
          ),
          // Search
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.search,
                builder: (_, _) => const SearchPage(),
              ),
            ],
          ),
          // Saved
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.liked,
                builder: (_, _) => const LikedPage(),
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.menuProfile,
                builder: (_, _) => const ProfilePage(userId: null),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.createPost,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return UploadPostPage(
            isEditMode: extra?['isEditMode'] ?? false,
            postId: extra?['postId'],
            existingTitle: extra?['existingTitle'],
            existingDescription: extra?['existingDescription'],
            existingImageUrl: extra?['existingImageUrl'],
          );
        },
      ),
      GoRoute(
        path: AppRoute.createCollection,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return CreateCollectionPage(
            // ==========================================
            // support create / edit collection
            // ==========================================
            isEditMode: extra?['isEditMode'] ?? false,
            collectionId: extra?['collectionId'],
            existingName: extra?['existingName'],
          );
        },
      ),
      GoRoute(
        path: AppRoute.imageDetail,
        builder: (context, state) => ImageDetailPage(post: state.extra as Post),
      ),
      GoRoute(
        path: AppRoute.profile,
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          return ProfilePage(userId: userId, key: ValueKey(userId));
        },
      ),
      GoRoute(
        path: AppRoute.collectionDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return CollectionsPage(
            // ==========================================
            // collection detail perlu id + name
            // ==========================================
            collectionId: extra?['collectionId'] ?? '',
            collectionName: extra?['collectionName'] ?? 'Collections Name',
            isDefault: extra?['isDefault'] ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoute.editProfile,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return EditProfilePage(
            existingUsername: extra?['existingUsername'],
            existingBio: extra?['existingBio'],
            existingPhotoUrl: extra?['existingPhotoUrl'],
          );
        },
      ),
      GoRoute(
        path: AppRoute.restoreAccount,
        builder: (context, state) => const RestoreAccountPage(),
      ),
      GoRoute(
        path: AppRoute.resendEmail,
        builder: (context, state) => const ResendEmailPage(),
      ),
    ],
  );
});
