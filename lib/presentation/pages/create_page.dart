import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_button.dart';
import 'upload_post_page.dart';
import 'create_collection_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header with X button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // X Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.secondary,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Title
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Divider(
              color: AppColors.primary,
              thickness: 1,
              height: 1,
            ),

            const SizedBox(height: 44),

            Center(
              child: Column(
                children: [
                  // Upload Post Button
                  AppButton(
                    label: 'Upload Post',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPostPage()),
                    ),
                    variant: AppButtonVariant.filled,
                  ),

                  const SizedBox(height: 16),

                  // Create Collection Button
                  AppButton(
                    label: 'Create Collection',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCollectionPage()),
                    ),
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
            ),
          ],
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