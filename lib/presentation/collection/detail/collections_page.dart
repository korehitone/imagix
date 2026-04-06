import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imagix/app/navigation/app_router.dart';
import 'package:imagix/core/utils/helper.dart';
import 'package:imagix/di/dependency_module.dart';
import 'package:imagix/domain/collection/model/collection_item.dart';
import 'package:imagix/presentation/common/pagination/paginated_state.dart';
import 'package:imagix/presentation/widgets/app_error_widget.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  final String collectionId;
  final String collectionName;
  final bool isDefault;

  const CollectionsPage({
    super.key,
    required this.collectionId,
    this.collectionName = 'Collections Name',
    this.isDefault = false,
  });

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  late String _currentCollectionName;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentCollectionName = widget.collectionName;
    Future.microtask(() {
      ref
          .read(
            DependencyModule.collectionDetailViewModelProvider(
              widget.collectionId,
            ).notifier,
          )
          .init(widget.collectionId);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref
          .read(
            DependencyModule.collectionDetailViewModelProvider(
              widget.collectionId,
            ).notifier,
          )
          .loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = DependencyModule.collectionDetailViewModelProvider(
      widget.collectionId,
    );

    ref.listen(provider, (prev, next) {
      if (next is AsyncError) {
        if (prev is AsyncError && prev?.error == next.error) return;
        context.showMsg(next.error.toString());
      }

      final data = next.value;

      if (data?.errorMessage != null && (data?.items.isNotEmpty ?? false)) {
        context.showMsg(data!.errorMessage!);
        ref.read(provider.notifier).clearError();
      }
    });

    // final state = ref.watch(provider);
    // final items = state.value;

    final state = ref.watch(provider);
    final data = state.value ?? PaginatedState<CollectionItem>.empty();
    final items = data.items;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Header row
              Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentCollectionName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Edit icon
                  if (!widget.isDefault) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await context.push(
                            AppRoute.createCollection,
                            extra: {
                              'isEditMode': true,
                              'collectionId': widget.collectionId,
                              'existingName': _currentCollectionName,
                            },
                          );

                          if (!context.mounted) return;

                          // ==========================================
                          // kalau edit sukses, update title lokal
                          // ==========================================
                          if (result is String && result.isNotEmpty) {
                            setState(() {
                              _currentCollectionName = result;
                            });
                          }
                        },
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                    ),

                    //
                    GestureDetector(
                      onTap: () {
                        _showDeleteCollectionConfirmation(context, ref);
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 26,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(provider.notifier).refresh(widget.collectionId),
                  child: data.isLoading && items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : data.errorMessage != null && items.isEmpty
                      ? AppErrorWidget(
                          errorMessage: state.error.toString(),
                          onRetry: () => ref
                              .read(provider.notifier)
                              .init(widget.collectionId),
                        )
                      : items.isEmpty
                      ? const Center(
                          child: Text("No items in this collection yet"),
                        )
                      : GridView.builder(
                          controller: _scrollController,
                          itemCount:
                              items.length + (data.isLoadingMore ? 2 : 0),
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 173 / 330,
                              ),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final item = items[index];
                            return _CollectionPostItem(
                              title: item.title,
                              imageUrl: item.image,
                              onTap: () async {
                                final post = await ref
                                    .read(
                                      DependencyModule.collectionDetailViewModelProvider(
                                        widget.collectionId,
                                      ).notifier,
                                    )
                                    .getPostDetail(item.postId);

                                if (!context.mounted || post == null) return;

                                context.push(AppRoute.imageDetail, extra: post);
                              },
                              onRemove: () {
                                _showRemoveConfirmation(
                                  context,
                                  ref,
                                  item.itemId,
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    WidgetRef ref,
    int itemId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Remove Item?"),
        content: const Text(
          "Are you sure want to remove this item from collection?.",
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(
                    DependencyModule.collectionDetailViewModelProvider(
                      widget.collectionId,
                    ).notifier,
                  )
                  .removeItem(widget.collectionId, itemId);

              dialogContext.pop();
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCollectionConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Collection?"),
        content: const Text("Are you sure want to delete this collection?."),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              dialogContext.pop();

              final isSuccess = await ref
                  .read(
                    DependencyModule.collectionDetailViewModelProvider(
                      widget.collectionId,
                    ).notifier,
                  )
                  .deleteCollection(widget.collectionId);

              if (!context.mounted) return;

              if (isSuccess) {
                context.showMsg("Collection deleted successfully!");
                context.pop();
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CollectionPostItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _CollectionPostItem({
    required this.title,
    required this.imageUrl,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 173 / 280,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                // ==========================================
                // REMOVE BUTTON
                // posisinya mirip save button di ImageItem
                // ==========================================
                onTap: onRemove,
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
