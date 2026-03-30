import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_image_upload_box.dart';
import '../widgets/app_text_field.dart';

class EditProfilePage extends StatefulWidget {
  final String? existingUsername;
  final String? existingEmail;
  final String? existingBio;

  const EditProfilePage({
    super.key,
    this.existingUsername,
    this.existingEmail,
    this.existingBio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  int _currentIndex = 4;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.existingUsername ?? '';
    _emailController.text = widget.existingEmail ?? '';
    _bioController.text = widget.existingBio ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
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
              child: AppHeader(title: 'Edit Profile'),
            ),

            const SizedBox(height: 8),

            // Divider edge to edge
            const Divider(
              color: AppColors.primary,
              thickness: 1,
              height: 1,
            ),

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
                        onTap: () {
                          // TODO: pick profile picture
                        },
                        width: 300,
                        height: 158,
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
                      ),

                      const SizedBox(height: 21),

                      // Email Section
                      _buildLabel('Email'),
                      const SizedBox(height: 21),
                      AppTextField(
                        hint: 'Email Field',
                        controller: _emailController,
                        width: 300,
                        height: 44,
                        keyboardType: TextInputType.emailAddress,
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
                      ),

                      const SizedBox(height: 21),

                      // Save Profile Button
                      AppButton(
                        label: 'Saved Profile',
                        onPressed: () {
                          // TODO: handle save profile
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