import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/widgets/app_image_box.dart';

import 'app_collection_picker_sheet.dart';

class ImageItem extends ConsumerWidget {
  final String? postId;
  final String? imageUrl;
  final String? title;
  final bool isOwner; // ← add this
  final VoidCallback? onTap;

  const ImageItem({
    super.key,
    this.postId,
    this.imageUrl,
    this.title,
    this.isOwner = false,
    this.onTap, // ← default to false (safer)
  });

  // void _openOverflowMenu(BuildContext context, WidgetRef ref) {
  //   AppOverflowMenu.show(
  //     context,
  //     items: [
  //       // AppOverflowMenuItem(
  //       //   icon: Icons.person_outline,
  //       //   label: 'Profile',
  //       //   onTap: () => Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(
  //       //       builder: (_) => ProfilePage(),
  //       //     ),
  //       //   ),
  //       // ),
  //       // Only show if user owns the post
  //       if (isOwner) ...[
  //         AppOverflowMenuItem(
  //           icon: Icons.edit_outlined,
  //           label: 'Edit',
  //           onTap: () {},
  //         ),
  //         AppOverflowMenuItem(
  //           icon: Icons.delete_outline,
  //           label: 'Delete',
  //           onTap: () {},
  //         ),
  //       ],
  //       // Only show if user does NOT own the post
  //       if (!isOwner)
  //         AppOverflowMenuItem(
  //           icon: Icons.bookmark_outline,
  //           label: 'Save',
  //           onTap:
  //         ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppImageBox(imageUrl: imageUrl, onTap: onTap),
        const SizedBox(height: 7),

        // Title + Ellipsis
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? "",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Builder(
                builder: (btnContext) => GestureDetector(
                  onTap: postId != null
                      ? () async {
                          final rootNavigator = Navigator.of(
                            context,
                            rootNavigator: true,
                          );

                          // Fetch data koleksi
                          await ref
                              .read(
                                DependencyModule.imageDetailViewModelProvider(
                                  postId!,
                                ).notifier,
                              )
                              .fetchUserCollection(postId!);

                          // Gunakan rootNavigator.context untuk memastikan sheet muncul di layer paling atas
                          if (rootNavigator.mounted) {
                            AppCollectionPickerSheet.show(
                              rootNavigator.context,
                              postId!,
                            );
                          }
                        }
                      : () {
                          // context.showMsg("UIIAI $postId");
                        },
                  // () => _openOverflowMenu(btnContext, ref),
                  child: const Icon(
                    Icons.bookmark_add_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
