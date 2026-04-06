import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';

import '../../core/theme/app_colors.dart';

class _CollectionData {
  final String name;

  const _CollectionData({required this.name});
}

const List<_CollectionData> _dummyCollections = [
  _CollectionData(name: 'Favorites'),
  _CollectionData(name: 'Inspiration'),
  _CollectionData(name: 'Art'),
  _CollectionData(name: 'Photography'),
];

class AppCollectionPickerSheet {
  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(
                  DependencyModule.imageDetailViewModelProvider(postId),
                );
                final data = state.value;

                return Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Save to Collection',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Divider(
                      color: AppColors.primary,
                      thickness: 1,
                      height: 1,
                    ),

                    // Collections List
                    Expanded(
                      child: data != null
                          ? (data.collections.isEmpty
                                ? const Center(
                                    child: Text("No collections yet"),
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    itemCount: data.collections.length,
                                    itemBuilder: (context, index) {
                                      final collection =
                                          data.collections[index];
                                      final bool alreadySaved =
                                          collection.isSaved;
                                      return ListTile(
                                        enabled: !alreadySaved,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                        leading: Container(
                                          // Bagian Icon di kiri
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: alreadySaved
                                                ? Colors.grey[200]
                                                : AppColors.secondary
                                                      .withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.collections_outlined,
                                            color: alreadySaved
                                                ? Colors.grey
                                                : AppColors.primary,
                                          ),
                                        ),
                                        title: Text(
                                          collection.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: alreadySaved
                                            ? const Text(
                                                "Saved",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              )
                                            : const Icon(Icons.chevron_right),
                                        onTap: () {
                                          ref
                                              .read(
                                                DependencyModule.imageDetailViewModelProvider(
                                                  postId,
                                                ).notifier,
                                              )
                                              .toggleSaveToCollection(
                                                collection.id,
                                                postId,
                                              );
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ))
                          : state.hasError && !state.isLoading
                          ? AppErrorWidget(
                              errorMessage: state.error.toString(),
                              onRetry: () {
                                ref
                                    .read(
                                      DependencyModule.imageDetailViewModelProvider(
                                        postId,
                                      ).notifier,
                                    )
                                    .fetchUserCollection(postId);
                              },
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
