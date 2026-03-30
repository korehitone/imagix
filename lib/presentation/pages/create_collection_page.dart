import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_button.dart';
import '../widgets/app_header.dart';
import '../widgets/app_text_field.dart';

class CreateCollectionPage extends StatefulWidget {
  final bool isEditMode;
  final String? existingName;

  const CreateCollectionPage({
    super.key,
    this.isEditMode = false,
    this.existingName,
  });

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  int _currentIndex = 2;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                title: widget.isEditMode ? 'Edit Collection' : 'Create Collection',
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

                      // Collection Name Label
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Collection Name',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      const SizedBox(height: 21),

                      // Collection Name Field
                      AppTextField(
                        hint: 'Collection Name Field',
                        controller: _nameController,
                        width: 300,
                        height: 44,
                      ),

                      const SizedBox(height: 21),

                      // Submit Button
                      AppButton(
                        label: widget.isEditMode ? 'Edit Collection' : 'Create Collection',
                        onPressed: () {
                          // TODO: handle create or edit collection
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
}