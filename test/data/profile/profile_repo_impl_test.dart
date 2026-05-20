import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imagix/core/network/result_state.dart';
import 'package:imagix/data/profile/repository/profile_repository_impl.dart';
import 'package:imagix/domain/profile/model/profile.dart';
import 'package:imagix/domain/profile/model/profile_request.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_repo_impl_test.mocks.dart';

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
  late ProfileRepositoryImpl repository;
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

    repository = ProfileRepositoryImpl(mockSupabaseClient);
  });

  final tProfileMap = {
    'id': 'user-123',
    'photo': null,
    'username': 'testuser',
    'bio': 'Hello!',
    'total_posts': 5,
    'total_collections': 2,
    'total_followers': 10,
    'total_followings': 3,
    'is_followed_by_me': false,
  };

  group('getProfilesByQuery', () {
    test('should return list of profiles on success', () async {
      when(mockSupabaseClient.from('profile_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.or(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.range(any, any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback([tProfileMap]));
      });

      final result = await repository.getProfilesByQuery(
        'test',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Success<List<Profile>>>());
      final data = (result as Success<List<Profile>>).data;
      expect(data.length, 1);
      expect(data.first.username, 'testuser');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('profile_view'))
          .thenThrow(Exception('Query failed'));

      final result = await repository.getProfilesByQuery(
        'test',
        offset: 0,
        limit: 20,
      );

      expect(result, isA<Error>());
    });
  });

  group('getProfile', () {
    test('should return profile on success', () async {
      when(mockSupabaseClient.from('profile_view'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(tProfileMap));
      });

      final result = await repository.getProfile('my-id', 'user-123');

      expect(result, isA<Success<Profile>>());
      final profile = (result as Success<Profile>).data;
      expect(profile.username, 'testuser');
    });

    test('should return Error when profile not found', () async {
      when(mockSupabaseClient.from('profile_view'))
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

      final result = await repository.getProfile('my-id', 'unknown');

      expect(result, isA<Error>());
      expect((result as Error).error, 'PROFILE_NOT_FOUND');
    });

    test('should return Error on exception', () async {
      when(mockSupabaseClient.from('profile_view'))
          .thenThrow(Exception('DB error'));

      final result = await repository.getProfile('my-id', 'user-123');

      expect(result, isA<Error>());
    });
  });

  group('updateProfile', () {
    test('should update profile without photo on success', () async {
      final request = ProfileRequest(username: 'newuser', bio: 'New bio');

      when(mockSupabaseClient.from('users'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.update(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({
          'id': 'user-123',
          'username': 'newuser',
          'bio': 'New bio',
          'email': 'test@test.com',
          'photo': null,
          'total_posts': 5,
          'total_collections': 2,
          'total_followers': 10,
          'total_followings': 3,
        }));
      });

      final result = await repository.updateProfile('user-123', request);

      expect(result, isA<Success<dynamic>>());
      verify(mockSupabaseBuilder.update({
        'username': 'newuser',
        'bio': 'New bio',
      }));
    });

    test('should update profile with photo on success', () async {
      final request = ProfileRequest(
        username: 'newuser',
        bio: 'New bio',
        photo: File('/tmp/test.jpg'),
      );

      when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(mockStorageClient.from('imagix')).thenReturn(mockFileApi);
      when(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')))
          .thenAnswer((_) async => 'uploaded.jpg');
      when(mockFileApi.getPublicUrl(any))
          .thenReturn('https://example.com/photo.jpg');

      when(mockSupabaseClient.from('users'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.update(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback({
          'id': 'user-123',
          'username': 'newuser',
          'bio': 'New bio',
          'email': 'test@test.com',
          'photo': 'https://example.com/photo.jpg',
        }));
      });

      final result = await repository.updateProfile('user-123', request);

      expect(result, isA<Success<dynamic>>());
      verify(mockFileApi.upload(any, any, fileOptions: anyNamed('fileOptions')));
      verify(mockFileApi.getPublicUrl(any));
    });

    test('should return Error when update returns null', () async {
      final request = ProfileRequest(username: 'newuser', bio: 'New bio');

      when(mockSupabaseClient.from('users'))
          .thenAnswer((_) => mockSupabaseBuilder);
      when(mockSupabaseBuilder.update(any))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.eq('id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.select())
          .thenAnswer((_) => mockFilterBuilderList);
      when(mockFilterBuilderList.maybeSingle())
          .thenAnswer((_) => mockFilterBuilderSingle);
      when(mockFilterBuilderSingle.then(any, onError: anyNamed('onError')))
          .thenAnswer((inv) {
        final callback = inv.positionalArguments[0] as Function;
        return Future.value(callback(null));
      });

      final result = await repository.updateProfile('user-123', request);

      expect(result, isA<Error>());
      expect((result as Error).error, 'UPDATE_PROFILE_FAILED');
    });

    test('should return Error on exception', () async {
      final request = ProfileRequest(username: 'newuser', bio: 'New bio');

      when(mockSupabaseClient.from('users'))
          .thenThrow(Exception('Update failed'));

      final result = await repository.updateProfile('user-123', request);

      expect(result, isA<Error>());
    });
  });
}
