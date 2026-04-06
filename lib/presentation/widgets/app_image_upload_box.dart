import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppImageUploadBox extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;
  final File? file;
  final String? imageUrl;

  const AppImageUploadBox({
    super.key,
    this.onTap,
    this.width = 300,
    this.height = 276,
    this.file,
    this.imageUrl,
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
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: _buildContent(),
        ),
        // file != null
        //     ? Image.file(file!, fit: BoxFit.cover)
        //     : Center(
        //         child: Icon(
        //           Icons.add_photo_alternate_outlined,
        //           color: AppColors.primary.withValues(alpha: 0.4),
        //           size: 64,
        //         ),
        //       ),
      ),
    );
  }

  Widget _buildContent() {
    // 1. Prioritas pertama: Tampilkan file lokal (kalau user baru milih gambar)
    if (file != null) {
      return Image.file(file!, fit: BoxFit.cover);
    }

    // 2. Prioritas kedua: Tampilkan URL (kalau lagi mode Edit)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _PlaceholderIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // 3. Default: Icon Plus (Kalau kosong semua)
    return const _PlaceholderIcon();
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        color: AppColors.primary.withValues(alpha: 0.4),
        size: 64,
      ),
    );
  }
}
