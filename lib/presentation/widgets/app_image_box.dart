import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppImageBox extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppImageBox({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.onTap,
  });

  static const _placeholderColors = [
    Color(0xFFF48FB1), // Pinkish
    Color(0xFF90CAF9), // Bluish
    Color(0xFFA5D6A7), // Greenish
    Color(0xFFFFF59D), // Yellowish
    Color(0xFFCE93D8), // Purplish
    Color(0xFFFFCC80), // Orangish
  ];

  @override
  Widget build(BuildContext context) {
    final persistentColor =
        _placeholderColors[Random().nextInt(_placeholderColors.length)];
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          height: height,
          color: persistentColor.withValues(alpha: 0.6),
          child: imageUrl != null
              ? Stack(
                  children: [
                    Image.network(
                      imageUrl!,
                      fit: height != null ? BoxFit.cover : BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Gambarnya udah jadi
                        }

                        return Container(
                          constraints: BoxConstraints(minHeight: height ?? 180),
                          alignment: Alignment.center,
                          color: persistentColor,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(context),
                    ),
                  ],
                )
              : _buildPlaceholder(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: 200, // Tinggi fix buat yang emang gak ada gambarnya
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: AppColors.primary.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
