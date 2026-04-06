import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_image_upload_box.dart';
import '../../widgets/app_text_field.dart';

class UploadPostPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  final String? postId;
  final String? existingTitle;
  final String? existingDescription;
  final String? existingImageUrl;

  const UploadPostPage({
    super.key,
    this.postId,
    this.isEditMode = false,
    this.existingTitle,
    this.existingDescription,
    this.existingImageUrl,
  });

  @override
  ConsumerState<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends ConsumerState<UploadPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    if (widget.isEditMode) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final vm = ref.read(DependencyModule.uploadViewModelProvider.notifier);

    if (title.isEmpty) {
      context.showMsg("Please input a title!");
      return;
    }

    if (widget.isEditMode) {
      vm.updatePost(
        postId: widget.postId!,
        title: title,
        description: description,
      );
    } else {
      if (_selectedImage == null) {
        context.showMsg("Please select an image first!");
        return;
      }
      vm.uploadPost(
        title: title,
        description: description,
        imageFile: _selectedImage,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.uploadViewModelProvider, (prev, next) {
      if (next is AsyncData) {
        // SEMUA REFRESH SUDAH DIHANDLE VIEWMODEL
        if (context.mounted) {
          context.pop(); // Balik ke halaman sebelumnya

          if (widget.isEditMode) {
            context.showMsg("Post updated successfully!");
          } else {
            // Mode Upload: Kasih SnackBar dengan tombol VIEW
            final newPost = next.value;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Post uploaded successfully!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                action: newPost != null
                    ? SnackBarAction(
                        label: "VIEW",
                        textColor: Colors.white,
                        onPressed: () => GoRouter.of(
                          context,
                        ).push(AppRoute.imageDetail, extra: newPost),
                      )
                    : null,
              ),
            );
          }
        }
        // Penting: Reset state upload biar gak trigger listener pas balik lagi
        ref.invalidate(DependencyModule.uploadViewModelProvider);
      }

      if (next is AsyncError) {
        context.showMsg(next.error.toString());
      }
    });
    final state = ref.watch(DependencyModule.uploadViewModelProvider);
    final isLoading = state is AsyncLoading;
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header (includes back button internally)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppHeader(
                title: widget.isEditMode ? 'Edit Post' : 'Upload Post',
              ),
            ),

            const SizedBox(height: 8),

            // Divider edge to edge
            const Divider(color: AppColors.primary, thickness: 1, height: 1),

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
                        file: _selectedImage,
                        imageUrl: widget.existingImageUrl,
                        onTap: (isLoading || widget.isEditMode)
                            ? null
                            : _pickImage,
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
                        enabled: !isLoading,
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
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 21),

                      // Submit Button
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        AppButton(
                          label: widget.isEditMode
                              ? 'Edit Post'
                              : 'Upload Post',
                          onPressed: () {
                            _submit();
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
    );
  }
}
