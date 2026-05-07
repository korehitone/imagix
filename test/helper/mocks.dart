import 'package:imagix/core/local/global_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {
  final GoTrueClient mockAuth;

  MockSupabaseClient(this.mockAuth);

  @override
  GoTrueClient get auth => mockAuth;
}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockPostgREST extends Mock implements PostgrestQueryBuilder {}

class MockStorageClient extends Mock implements SupabaseStorageClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockUser extends Mock implements User {}

class MockGlobalPreferences extends Mock implements GlobalPreferences {}

class MockAuthResponse extends Mock implements AuthResponse {
  @override
  User? user;

  @override
  Session? session;
}
