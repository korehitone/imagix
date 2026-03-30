import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env/env.dart';
import 'dependency_module.dart';

class DepedencyManager {
  late final SharedPreferences _sharedPreferences;

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inisialisasi semua yang Future di sini
    await Supabase.initialize(url: Env.apiBaseUrl, anonKey: Env.apiKey);

    _sharedPreferences = await SharedPreferences.getInstance();
  }

  List<dynamic> get overrides => [
    DependencyModule.sharedPrefProvider.overrideWithValue(_sharedPreferences),
  ];
}
