import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_image_upload_box.dart';
import '../widgets/app_text_field.dart';

class UploadPostPage extends StatefulWidget {
  final bool isEditMode;
  final String? existingTitle;
  final String? existingDescription;

  const UploadPostPage({
    super.key,
    this.isEditMode = false,
    this.existingTitle,
    this.existingDescription,
  });

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  int _currentIndex = 2;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.existingTitle ?? '';
    _descriptionController.text = widget.existingDescription ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppHeader(
                title: widget.isEditMode ? 'Edit Post' : 'Upload Post',
              ),
            ),

            const SizedBox(height: 8),

            // Divider edge to edge
            const Divider(
              color: AppColors.primary,
              thickness: 1,
              height: 1,
            ),

            const SizedBox(height: 44),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // Image Section
                      _buildLabel('Image'),
                      const SizedBox(height: 21),
                      AppImageUploadBox(
                        onTap: () {
                          // TODO: pick image from gallery
                        },
                      ),
                      const SizedBox(height: 21),

                      // Title Section
                      _buildLabel('Title'),
                      const SizedBox(height: 21),
                      AppTextField(
                        hint: 'Title Field',
                        controller: _titleController,
                        width: 300,
                        height: 44,
                      ),
                      const SizedBox(height: 21),

                      // Description Section
                      _buildLabel('Description'),
                      const SizedBox(height: 21),
                      AppTextField(
                        hint: 'Description Field',
                        controller: _descriptionController,
                        width: 300,
                        height: 74,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 21),

                      // Submit Button
                      AppButton(
                        label: widget.isEditMode ? 'Edit Post' : 'Upload Post',
                        onPressed: () {
                          // TODO: handle upload or edit
                        },
                        variant: AppButtonVariant.filled,
                        width: 300,
                        height: 44,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
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

  Widget _buildLabel(String text) {
    return SizedBox(
      width: 300,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}