import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_text_field.dart';

class CreateCollectionPage extends ConsumerStatefulWidget {
  final bool isEditMode;
  final String? collectionId;
  final String? existingName;

  const CreateCollectionPage({
    super.key,
    this.isEditMode = false,
    this.existingName,
    this.collectionId,
  });

  @override
  ConsumerState<CreateCollectionPage> createState() =>
      _CreateCollectionPageState();
}

class _CreateCollectionPageState extends ConsumerState<CreateCollectionPage> {
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

  void _submit() {
    final title = _nameController.text.trim();

    if (title.isEmpty) {
      context.showMsg("Collection name can not be empty.");
      return;
    }

    final vm = ref.read(
      DependencyModule.collectionFormViewModelProvider.notifier,
    );

    if (widget.isEditMode) {
      vm.updateCollection(collectionId: widget.collectionId!, title: title);
    } else {
      vm.createCollection(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(DependencyModule.collectionFormViewModelProvider, (prev, next) {
      if (next is AsyncError) {
        context.showMsg(next.error.toString());
        return;
      }

      if (prev is AsyncLoading && next is AsyncData && next.value == true) {
        context.pop(_nameController.text.trim());

        // reset provider biar aman saat buka lagi
        ref.invalidate(DependencyModule.collectionFormViewModelProvider);
      }
    });

    final state = ref.watch(DependencyModule.collectionFormViewModelProvider);
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
                title: widget.isEditMode
                    ? 'Edit Collection'
                    : 'Create Collection',
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
                      // Collection Name Label
                      _buildLabel('Collection Name'),

                      const SizedBox(height: 21),

                      // Collection Name Field
                      AppTextField(
                        hint: 'Collection Name Field',
                        controller: _nameController,
                        width: 300,
                        height: 44,
                        enabled: !isLoading,
                      ),

                      const SizedBox(height: 21),

                      // Submit Button
                      if (isLoading)
                        const CircularProgressIndicator()
                      else
                        AppButton(
                          label: widget.isEditMode
                              ? 'Edit Collection'
                              : 'Create Collection',
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
