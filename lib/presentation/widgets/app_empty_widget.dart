import 'package:flutter/material.dart';

class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const AppEmptyWidget({
    super.key,
    this.title = "Whoops there is no data in server!",
    this.subtitle = "...(*￣０￣)ノ",
    this.icon = Icons.auto_awesome_motion_rounded, // Icon estetik ala Pinterest
  });

  @override
  Widget build(BuildContext context) {
    // Pake ListView + AlwaysScrollable biar RefreshIndicator tetep bisa ditarik
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          height:
              MediaQuery.of(context).size.height * 0.7, // Biar pas di tengah
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
