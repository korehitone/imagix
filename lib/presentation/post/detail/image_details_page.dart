import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/post/model/post.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_image_details.dart';

class ImageDetailPage extends ConsumerStatefulWidget {
  final Post post;
  final String? imageUrl;

  const ImageDetailPage({super.key, required this.post, this.imageUrl});

  @override
  ConsumerState<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends ConsumerState<ImageDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(
            DependencyModule.imageDetailViewModelProvider(
              widget.post.id,
            ).notifier,
          )
          .init(widget.post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = DependencyModule.imageDetailViewModelProvider(
      widget.post.id,
    );

    ref.listen(provider, (prev, next) {
      final data = next.value;

      if (next is AsyncError) {
        if (prev is AsyncError && prev?.error == next.error) return;
        context.showMsg(next.error.toString());
      }

      if (data?.errorMessage != null) {
        context.showMsg(data!.errorMessage!);
        ref.read(provider.notifier).clearError();
      }

      if (data?.isDeleted == true) {
        ref.read(provider.notifier).resetDeleted();

        if (!context.mounted) return;

        context.showMsg("Post deleted successfully!");
        context.pop();
      }
    });

    final state = ref.watch(provider);
    final post = state.value?.post;

    if (state.isLoading && post == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (state.hasError && post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: Center(child: Text(state.error.toString()))),
      );
    }

    final currentData = post ?? widget.post;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: currentData.image.isNotEmpty
                        ? Image.network(currentData.image, fit: BoxFit.contain)
                        : const _ImagePlaceholder(),
                  ),
                ),
              ),
              AppImageActions(
                title: currentData.title,
                description: currentData.description,
                ownerId: currentData.userId,
                ownerPhoto: currentData.authorPhoto,
                ownerName: currentData.authorUsername,
                postId: currentData.id,
                onProfileTap: () {
                  context.push(AppRoute.profileWithId(currentData.userId));
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            "Image not available",
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
