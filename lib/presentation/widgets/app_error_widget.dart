import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String? title;

  const AppErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            // Icon dibuat lebih 'glow' atau subtle
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),

            // Judul lebih tegas
            Text(
              title ?? "Whoops, Something Wrong!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Error Message diperjelas warnanya
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface, // Lebih terang biar kebaca
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Button dibuat lebih dinamis (Gak kaku)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary, width: 2),
                    // Kita kasih efek gradient tipis atau warna solid yang pas
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Try Again",
                        style: TextStyle(
                          color:
                              AppColors.primary, // Tulisan ngikutin warna brand
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
