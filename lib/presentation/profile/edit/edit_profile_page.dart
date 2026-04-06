import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_image_upload_box.dart';
import '../../widgets/app_text_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final String? existingUsername;
  final String? existingBio;
  final String? existingPhotoUrl;

  const EditProfilePage({
    super.key,
    this.existingUsername,
    this.existingBio,
    this.existingPhotoUrl,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.existingUsername ?? '';
    _bioController.text = widget.existingBio ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;

    setState(() {
      _selectedImage = File(file.path);
    });
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      context.showMsg("Username can not be empty.");
      return;
    }

    ref
        .read(DependencyModule.profileFormViewModelProvider.notifier)
        .updateProfile(username: username, bio: bio, photo: _selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.profileFormViewModelProvider, (prev, next) {
      if (next is AsyncError) {
        context.showMsg(next.error.toString());
        return;
      }

      if (prev is AsyncLoading && next is AsyncData && next.value == true) {
        context.showMsg("Profile updated successfully!");
        context.pop();
        ref.invalidate(DependencyModule.profileFormViewModelProvider);
      }
    });
    final state = ref.watch(DependencyModule.profileFormViewModelProvider);
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
              child: AppHeader(title: 'Edit Profile'),
            ),

            const SizedBox(height: 8),

            // Divider edge to edge
            const Divider(color: AppColors.primary, thickness: 1, height: 1),

            const SizedBox(height: 47),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture Section
                      _buildLabel('Profile Picture'),
                      const SizedBox(height: 21),
                      AppImageUploadBox(
                        onTap: isLoading ? null : _pickImage,
                        width: 300,
                        height: 158,
                        file: _selectedImage,
                        imageUrl: widget.existingPhotoUrl,
                      ),

                      const SizedBox(height: 21),

                      // Username Section
                      _buildLabel('Username'),
                      const SizedBox(height: 21),
                      AppTextField(
                        hint: 'Title Field',
                        controller: _usernameController,
                        width: 300,
                        height: 44,
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 21),

                      // Bio Section
                      _buildLabel('Bio'),
                      const SizedBox(height: 21),
                      AppTextField(
                        hint: 'Description Field',
                        controller: _bioController,
                        width: 300,
                        height: 74,
                        maxLines: 4,
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 21),

                      // Save Profile Button
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        AppButton(
                          label: 'Save Profile',
                          onPressed: _submit,
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
