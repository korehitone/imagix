import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/app/app_dart.dart';
import 'package:imagix/di/dependency_manager.dart';

void main() async {
  final di = DependencyManager();
  await di.init();
  runApp(
    ProviderScope(overrides: di.overrides.cast(), child: const ImagixApp()),
  );
}
