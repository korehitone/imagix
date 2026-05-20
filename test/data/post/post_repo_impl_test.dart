import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/post/repository/post_repository_impl.dart';
import 'package:imagix/domain/post/model/post.dart';
import 'package:imagix/domain/post/model/post_request.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'post_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<SupabaseQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder<List<Map<String, dynamic>>>>(
    as: #MockPostgrestFilterBuilderList,
  ),
  MockSpec<PostgrestFilterBuilder<Map<String, dynamic>?>>(
    as: #MockPostgrestFilterBuilderSingle,
  ),
  MockSpec<SupabaseStorageClient>(),
  MockSpec<StorageFileApi>(),
])
void main() {
  late PostRepositoryImpl repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseBuilder;
  late MockPostgrestFilterBuilderList mockFilterBuilderList;
  late MockPostgrestFilterBuilderSingle mockFilterBuilderSingle;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockFileApi;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilderList = MockPostgrestFilterBuilderList();
    mockFilterBuilderSingle = MockPostgrestFilterBuilderSingle();
    mockStorageClient = MockSupabaseStorageClient();
    mockFileApi = MockStorageFileApi();

    repository = PostRepositoryImpl(mockSupabaseClient);
  });

  final tNow = DateTime.now().toIso8601String();
  final tPostMap = {
    'id': 'post-123',
    'title': 'Test Post',
    'description': 'A test post',
    'image': 'https://example.com/image.jpg',
    'user_id': 'user-123',
    'author_username': 'testuser',
    'author_photo': null,
    'total_likes': 10,
    'total_comments': 5,
    'is_liked': false,
    'created_at': tNow,
    'updated_at': tNow,
  };

  group('getPosts', () {
    test('should return list of posts on success', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.order('created_at', ascending: true))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.range(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback([tPostMap]));
      });

      final result = await repository.getPosts(offset: 0, limit: 20);

      expect(result, isA<Success<List<Post>>>());
      final data = (result as Success<List<Post>>).data;
      expect(data.length, 1);
      expect(data.first.title, 'Test Post');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenThrow(Exception('Query failed'));

      final result = await repository.getPosts(offset: 0, limit: 20);

      expect(result, isA<Error>());
    });
  });

  group('getPost', () {
    test('should return post on success', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'post-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(tPostMap));
      });

      final result = await repository.getPost('post-123');

      expect(result, isA<Success<Post>>());
      expect((result as Success<Post>).data.title, 'Test Post');
    });

    test('should return Error when post not found', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'unknown'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.getPost('unknown');

      expect(result, isA<Error>());
      expect((result as Error).error, 'POST_NOT_FOUND');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenThrow(Exception('DB error'));

      final result = await repository.getPost('post-123');

      expect(result, isA<Error>());
    });
  });

  group('getUserPosts', () {
    test('should return user posts on success', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('user_id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.order('created_at', ascending: true))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.range(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback([tPostMap]));
      });

      final result = await repository.getUserPosts(
        'user-123',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Success<List<Post>>>());
      final data = (result as Success<List<Post>>).data;
      expect(data.length, 1);
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenThrow(Exception('Failed'));

      final result = await repository.getUserPosts(
        'user-123',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Error>());
    });
  });

  group('getLikedPosts', () {
    test('should return liked posts on success', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('is_liked', true))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.order('created_at', ascending: false))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.range(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback([tPostMap]));
      });

      final result = await repository.getLikedPosts(offset: 0, limit: 20);

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success<List<Post>>).data.length, 1);
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenThrow(Exception('Failed'));

      final result = await repository.getLikedPosts(offset: 0, limit: 20);

      expect(result, isA<Error>());
    });
  });

  group('getPostsByQuery', () {
    test('should return posts matching query on success', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.or(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.order('created_at', ascending: true))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.range(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback([tPostMap]));
      });

      final result = await repository.getPostsByQuery(
        'test',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Success<List<Post>>>());
      expect((result as Success<List<Post>>).data.length, 1);
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('post_list_view'))
          .thenThrow(Exception('Query failed'));

      final result = await repository.getPostsByQuery(
        'test',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Error>());
    });
  });

  group('create', () {
    test('should create post on success', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockStorageClient.from('imagix')).thenReturn(mockFileApi);
      when(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')))
          .thenAnswer((_) async => 'uploaded.jpg');
      when(mockFileApi.getPublicUrl(any))
          .thenReturn('https://example.com/post.jpg');

      final mockPostsBuilder = MockSupabaseQueryBuilder();
      final mockInsertFilter = MockPostgrestFilterBuilderList();
      final mockInsertSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockPostsBuilder);
      when(mockPostsBuilder.insert(any))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.select('id'))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.maybeSingle())
          .thenAnswer((_) => mockInsertSingle);
      when(mockInsertSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({'id': 'new-post-id'}));
      });

      final mockViewBuilder = MockSupabaseQueryBuilder();
      final mockViewFilter = MockPostgrestFilterBuilderList();
      final mockViewSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockViewBuilder);
      when(mockViewBuilder.select())
          .thenAnswer((_) => mockViewFilter);
      when(mockViewFilter.eq('id', 'new-post-id'))
          .thenAnswer((_) => mockViewFilter);
      when(mockViewFilter.maybeSingle())
          .thenAnswer((_) => mockViewSingle);
      when(mockViewSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(tPostMap));
      });

      final result = await repository.create('user-123', request);

      expect(result, isA<Success<Post>>());
      expect((result as Success<Post>).data.title, 'Test Post');
    });

    test('should return Error when insert returns null', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockStorageClient.from('imagix')).thenReturn(mockFileApi);
      when(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')))
          .thenAnswer((_) async => 'uploaded.jpg');
      when(mockFileApi.getPublicUrl(any))
          .thenReturn('https://example.com/post.jpg');

      final mockPostsBuilder = MockSupabaseQueryBuilder();
      final mockInsertFilter = MockPostgrestFilterBuilderList();
      final mockInsertSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockPostsBuilder);
      when(mockPostsBuilder.insert(any))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.select('id'))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.maybeSingle())
          .thenAnswer((_) => mockInsertSingle);
      when(mockInsertSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.create('user-123', request);

      expect(result, isA<Error>());
      expect((result as Error).error, 'POST_CREATE_FAILED');
    });

    test('should return Error when view refetch returns null', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockStorageClient.from('imagix')).thenReturn(mockFileApi);
      when(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')))
          .thenAnswer((_) async => 'uploaded.jpg');
      when(mockFileApi.getPublicUrl(any))
          .thenReturn('https://example.com/post.jpg');

      final mockPostsBuilder = MockSupabaseQueryBuilder();
      final mockInsertFilter = MockPostgrestFilterBuilderList();
      final mockInsertSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockPostsBuilder);
      when(mockPostsBuilder.insert(any))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.select('id'))
          .thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.maybeSingle())
          .thenAnswer((_) => mockInsertSingle);
      when(mockInsertSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({'id': 'new-post-id'}));
      });

      final mockViewBuilder = MockSupabaseQueryBuilder();
      final mockViewFilter = MockPostgrestFilterBuilderList();
      final mockViewSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('post_list_view'))
          .thenAnswer((_) => mockViewBuilder);
      when(mockViewBuilder.select())
          .thenAnswer((_) => mockViewFilter);
      when(mockViewFilter.eq('id', 'new-post-id'))
          .thenAnswer((_) => mockViewFilter);
      when(mockViewFilter.maybeSingle())
          .thenAnswer((_) => mockViewSingle);
      when(mockViewSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.create('user-123', request);

      expect(result, isA<Error>());
      expect((result as Error).error, 'POST_CREATED_BUT_NOT_READABLE');
    });

    test('should return Error on exception', () async {
      final request = PostRequest(
        title: 'New Post',
        description: 'New description',
        imageFile: File('/tmp/test.jpg'),
      );

      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockStorageClient.from('imagix')).thenReturn(mockFileApi);
      when(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')))
          .thenAnswer((_) async => 'uploaded.jpg');
      when(mockFileApi.getPublicUrl(any))
          .thenReturn('https://example.com/post.jpg');

      when(mockSupabaseClient.from('posts'))
          .thenThrow(Exception('Create failed'));

      final result = await repository.create('user-123', request);

      expect(result, isA<Error>());
    });
  });

  group('update', () {
    test('should update post on success', () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.update(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select('id'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({'id': 'post-123'}));
      });

      final result = await repository.update('user-123', 'post-123', request);

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Error when update returns null', () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.update(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select('id'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.update('user-123', 'post-123', request);

      expect(result, isA<Error>());
      expect((result as Error).error, 'POST_UPDATE_FAILED_OR_DENIED');
    });

    test('should return Error on exception', () async {
      final request = PostRequest(
        title: 'Updated Title',
        description: 'Updated description',
      );

      when(mockSupabaseClient.from('posts'))
          .thenThrow(Exception('Update failed'));

      final result = await repository.update('user-123', 'post-123', request);

      expect(result, isA<Error>());
    });
  });

  group('delete', () {
    test('should delete post on success', () async {
      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.delete())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select('id'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({'id': 'post-123'}));
      });

      final result = await repository.delete('user-123', 'post-123');

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should return Error when delete returns null', () async {
      when(mockSupabaseClient.from('posts'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.delete())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select('id'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.delete('user-123', 'post-123');

      expect(result, isA<Error>());
      expect((result as Error).error, 'POST_DELETE_FAILED_OR_DENIED');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('posts'))
          .thenThrow(Exception('Delete failed'));

      final result = await repository.delete('user-123', 'post-123');

      expect(result, isA<Error>());
    });
  });

  group('toggleLike', () {
    test('should insert like and return true when not yet liked', () async {
      final mockLikesBuilder = MockSupabaseQueryBuilder();
      final mockSelectFilter = MockPostgrestFilterBuilderList();
      final mockSelectSingle = MockPostgrestFilterBuilderSingle();
      final mockInsertFilter = MockPostgrestFilterBuilderList();
      final mockInsertSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('likes')).thenAnswer((_) => mockLikesBuilder);

      when(mockLikesBuilder.select()).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.eq(any, any)).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.maybeSingle()).thenAnswer((_) => mockSelectSingle);
      when(mockSelectSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      when(mockLikesBuilder.insert(any)).thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.select('id')).thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.maybeSingle()).thenAnswer((_) => mockInsertSingle);
      when(mockInsertSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({'id': 1}));
      });

      final result = await repository.toggleLike('user-123', 'post-123');

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('should delete like and return false when already liked', () async {
      final mockLikesBuilder = MockSupabaseQueryBuilder();
      final mockSelectFilter = MockPostgrestFilterBuilderList();
      final mockSelectSingle = MockPostgrestFilterBuilderSingle();
      final mockDeleteFilter = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('likes')).thenAnswer((_) => mockLikesBuilder);

      when(mockLikesBuilder.select()).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.eq(any, any)).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.maybeSingle()).thenAnswer((_) => mockSelectSingle);
      when(mockSelectSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({
          'id': 1,
          'post_id': 'post-123',
          'user_id': 'user-123',
        }));
      });

      when(mockLikesBuilder.delete()).thenAnswer((_) => mockDeleteFilter);
      when(mockDeleteFilter.eq(any, any)).thenAnswer((_) => mockDeleteFilter);
      when(mockDeleteFilter.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.toggleLike('user-123', 'post-123');

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, false);
    });

    test('should return Error when insert returns null', () async {
      final mockLikesBuilder = MockSupabaseQueryBuilder();
      final mockSelectFilter = MockPostgrestFilterBuilderList();
      final mockSelectSingle = MockPostgrestFilterBuilderSingle();
      final mockInsertFilter = MockPostgrestFilterBuilderList();
      final mockInsertSingle = MockPostgrestFilterBuilderSingle();

      when(mockSupabaseClient.from('likes')).thenAnswer((_) => mockLikesBuilder);

      when(mockLikesBuilder.select()).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.eq(any, any)).thenAnswer((_) => mockSelectFilter);
      when(mockSelectFilter.maybeSingle()).thenAnswer((_) => mockSelectSingle);
      when(mockSelectSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      when(mockLikesBuilder.insert(any)).thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.select('id')).thenAnswer((_) => mockInsertFilter);
      when(mockInsertFilter.maybeSingle()).thenAnswer((_) => mockInsertSingle);
      when(mockInsertSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.toggleLike('user-123', 'post-123');

      expect(result, isA<Error>());
      expect((result as Error).error, 'LIKE_FAILED');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('likes'))
          .thenThrow(Exception('Like failed'));

      final result = await repository.toggleLike('user-123', 'post-123');

      expect(result, isA<Error>());
    });
  });
}
