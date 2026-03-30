import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppImageUploadBox extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;

  const AppImageUploadBox({
    super.key,
    this.onTap,
    this.width = 300,
    this.height = 276,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.primary.withValues(alpha: 0.4),
            size: 64,
          ),
        ),
      ),
    );
  }
}