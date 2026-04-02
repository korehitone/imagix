import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_image_details.dart';

class ImageDetailPage extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String description;

  const ImageDetailPage({
    super.key,
    this.imageUrl,
    this.title = 'Image Title',
    this.description = 'Description',
  });

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Back Button
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),

              const SizedBox(height: 12),

              // Image
              Center(
                child: Container(
                  width: 364,
                  height: 539,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            'Image',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                ),
                          ),
                        ),
                ),
              ),

              // Actions + Title + Description
              AppImageActions(
                title: widget.title,
                description: widget.description,
              ),

              SizedBox(height: 80 + MediaQuery.of(context).padding.bottom), // padding for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}