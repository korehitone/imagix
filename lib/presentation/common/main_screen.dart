import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // Ini otomatis nampung halaman tab-nya
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex >= 2
            ? navigationShell.currentIndex + 1
            : navigationShell.currentIndex,
        onTap: (index) {
          if (index == 2) {
            return;
          }
          // Navigasi antar tab tanpa ngerusak state scroll
          int routerIndex = index > 2 ? index - 1 : index;
          navigationShell.goBranch(
            routerIndex,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
