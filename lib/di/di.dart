import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/core/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DI {
  static Future<void> init() async {
    await Supabase.initialize(url: Env.apiBaseUrl, anonKey: Env.apiKey);
  }

  final supabaseProvider = Provider<SupabaseClient>(
    (ref) => Supabase.instance.client,
  );
}
