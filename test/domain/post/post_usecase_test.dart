import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/domain/auth/repository/auth_repository.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'post_usecase_test.mocks.dart';

@GenerateMocks([PostRepository, AuthRepository])
void main() {
  provideDummy<ResultState<Post>>(
    Success(Post(
      id: '',
      title: '',
      description: '',
      image: '',
      userId: '',
      authorUsername: '',
      totalLikes: 0,
      totalComments: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    )),
  );
  provideDummy<ResultState<List<Post>>>(Success([]));
  provideDummy<ResultState<bool>>(const Success(true));

  late MockPostRepository mockPostRepo;
  late MockAuthRepository mockAuthRepo;
  late GetPostsUseCase getPostsUC;
  late GetPostUseCase getPostUC;
  late GetLikedPostsUseCase getLikedPostsUC;
  late GetPostsByQueryUseCase getPostsByQueryUC;
  late GetUserPostsUseCase getUserPostsUC;
  late CreatePostUseCase createPostUC;
  late UpdatePostUseCase updatePostUC;
  late DeletePostUseCase deletePostUC;
  late ToggleLikeUseCase toggleLikeUC;

  setUp(() {
    mockPostRepo = MockPostRepository();
    mockAuthRepo = MockAuthRepository();
    getPostsUC = GetPostsUseCase(mockPostRepo);
    getPostUC = GetPostUseCase(mockPostRepo, mockAuthRepo);
    getLikedPostsUC = GetLikedPostsUseCase(mockPostRepo, mockAuthRepo);
    getPostsByQueryUC = GetPostsByQueryUseCase(mockPostRepo);
    getUserPostsUC = GetUserPostsUseCase(mockPostRepo);
    createPostUC = CreatePostUseCase(mockPostRepo, mockAuthRepo);
    updatePostUC = UpdatePostUseCase(mockPostRepo, mockAuthRepo);
    deletePostUC = DeletePostUseCase(mockPostRepo, mockAuthRepo);
    toggleLikeUC = ToggleLikeUseCase(mockPostRepo, mockAuthRepo);
  });

  const tUserId = 'uid-123';
  const tPostId = 'post-456';

  final tSupabaseUser = supabase.User(
    id: tUserId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );

  final tPost = Post(
    id: tPostId,
    title: 'Test Post',
    description: 'A test post',
    image: 'https://example.com/image.jpg',
    userId: tUserId,
    authorUsername: 'testuser',
    totalLikes: 10,
    totalComments: 5,
    isLiked: false,
    createdAt: DateTime.now(),
  );

  final tPostList = [tPost];

  group('GetPostsUseCase', () {
    test('should return list of posts from repository', () async {
      when(
        mockPostRepo.getPosts(offset: 0, limit: 20),
      ).thenAnswer((_) async => Success(tPostList));

      final result = await getPostsUC.invoke(offset: 0, limit: 20);

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success).data, tPostList);
      verify(mockPostRepo.getPosts(offset: 0, limit: 20)).called(1);
    });
  });

  group('GetPostUseCase', () {
    test('should return post when authenticated', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.getPost(tPostId))
          .thenAnswer((_) async => Success(tPost));

      final result = await getPostUC.invoke(tPostId);

      expect(result, isA<Success<Post>>());
      expect((result as Success<Post>).data, tPost);
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await getPostUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map POST_NOT_FOUND to user-friendly message', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.getPost(any))
          .thenAnswer((_) async => const Error("POST_NOT_FOUND"));

      final result = await getPostUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect((result as Error).error, "User profile not found.");
    });
  });

  group('GetLikedPostsUseCase', () {
    test('should return liked posts when authenticated', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(
        mockPostRepo.getLikedPosts(offset: 0, limit: 20),
      ).thenAnswer((_) async => Success(tPostList));

      final result = await getLikedPostsUC.invoke(offset: 0, limit: 20);

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success).data, tPostList);
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await getLikedPostsUC.invoke(offset: 0, limit: 20);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });
  });

  group('GetPostsByQueryUseCase', () {
    test('should return posts matching query from repository', () async {
      when(
        mockPostRepo.getPostsByQuery('test', offset: 0, limit: 20),
      ).thenAnswer((_) async => Success(tPostList));

      final result = await getPostsByQueryUC.invoke(
        'test',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success).data, tPostList);
      verify(
        mockPostRepo.getPostsByQuery('test', offset: 0, limit: 20),
      ).called(1);
    });
  });

  group('GetUserPostsUseCase', () {
    test('should return user posts from repository', () async {
      when(
        mockPostRepo.getUserPosts(tUserId, offset: 0, limit: 20),
      ).thenAnswer((_) async => Success(tPostList));

      final result = await getUserPostsUC.invoke(
        tUserId,
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success).data, tPostList);
      verify(
        mockPostRepo.getUserPosts(tUserId, offset: 0, limit: 20),
      ).called(1);
    });
  });

  group('CreatePostUseCase', () {
    test('should create post when authenticated and request is valid',
        () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.create(tUserId, request))
          .thenAnswer((_) async => Success(tPost));

      final result = await createPostUC.invoke(request);

      expect(result, isA<Success<Post>>());
      expect((result as Success<Post>).data, tPost);
    });

    test('should return Error when title is empty', () async {
      final request = PostRequest(title: '', description: 'New description');

      final result = await createPostUC.invoke(request);

      expect(result, isA<Error>());
      expect((result as Error).error, "Title is required.");
      verifyNever(mockPostRepo.create(any, any));
    });

    test('should return Error when imageFile is null', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
      );

      final result = await createPostUC.invoke(request);

      expect(result, isA<Error>());
      expect((result as Error).error, "An image required for new post.");
    });

    test('should return Error when session is null', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await createPostUC.invoke(request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map POST_CREATE_FAILED to user-friendly message', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.create(any, any))
          .thenAnswer((_) async => const Error("POST_CREATE_FAILED"));

      final result = await createPostUC.invoke(request);

      expect(result, isA<Error>());
      expect((result as Error).error, "Failed to upload post.");
    });

    test(
        'should map POST_CREATED_BUT_NOT_READABLE to user-friendly message',
        () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.create(any, any)).thenAnswer(
        (_) async => const Error("POST_CREATED_BUT_NOT_READABLE"),
      );

      final result = await createPostUC.invoke(request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Post uploaded, but failed to refresh post data.",
      );
    });
  });

  group('UpdatePostUseCase', () {
    test('should update post when authenticated and title is valid', () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.update(tUserId, tPostId, request))
          .thenAnswer((_) async => const Success(true));

      final result = await updatePostUC.invoke(tPostId, request);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Error when title is empty', () async {
      final request = PostRequest(title: '', description: 'New description');

      final result = await updatePostUC.invoke(tPostId, request);

      expect(result, isA<Error>());
      expect((result as Error).error, "Title can not be empty.");
      verifyNever(mockPostRepo.update(any, any, any));
    });

    test('should return Error when session is null', () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await updatePostUC.invoke(tPostId, request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map POST_UPDATE_FAILED_OR_DENIED to user-friendly message',
        () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.update(any, any, any))
          .thenAnswer((_) async => const Error("POST_UPDATE_FAILED_OR_DENIED"));

      final result = await updatePostUC.invoke(tPostId, request);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Update failed. Access denied.",
      );
    });
  });

  group('DeletePostUseCase', () {
    test('should delete post when authenticated', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.delete(tUserId, tPostId))
          .thenAnswer((_) async => const Success(true));

      final result = await deletePostUC.invoke(tPostId);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await deletePostUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map POST_DELETE_FAILED_OR_DENIED to user-friendly message',
        () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.delete(any, any))
          .thenAnswer((_) async => const Error("POST_DELETE_FAILED_OR_DENIED"));

      final result = await deletePostUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Delete failed. Access denied.",
      );
    });
  });

  group('ToggleLikeUseCase', () {
    test('should return true when post is liked', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.toggleLike(tUserId, tPostId))
          .thenAnswer((_) async => const Success(true));

      final result = await toggleLikeUC.invoke(tPostId);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return false when post is unliked', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.toggleLike(tUserId, tPostId))
          .thenAnswer((_) async => const Success(false));

      final result = await toggleLikeUC.invoke(tPostId);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, false);
    });

    test('should return Error when session is null', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(null);

      final result = await toggleLikeUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Session expired. Please sign in again.",
      );
    });

    test('should map LIKE_FAILED to user-friendly message', () async {
      when(mockAuthRepo.getCurrentUser()).thenReturn(tSupabaseUser);
      when(mockPostRepo.toggleLike(any, any))
          .thenAnswer((_) async => const Error("LIKE_FAILED"));

      final result = await toggleLikeUC.invoke(tPostId);

      expect(result, isA<Error>());
      expect(
        (result as Error).error,
        "Failed to like post.",
      );
    });
  });
}
