import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_collection_card.dart';
import '../widgets/app_image_card.dart';
import '../widgets/app_search_bar.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _currentIndex = 3;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            slivers: [
              // Search Bar & Collections Header
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    AppSearchBar(
                      controller: _searchController,
                      onSearchTap: () {
                        // TODO: handle search
                      },
                    ),
                    const SizedBox(height: 24),

                    // Collections Header
                    Text(
                      'Collections',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Collections Grid
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AppCollectionCard(
                    title: 'Title',
                  ),
                  childCount: 4,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 5,
                  childAspectRatio: 173 / 151,
                ),
              ),

              // Last Added Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Text(
                    'Last Added',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // Images Grid
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AppDetails(
                    title: 'Title',
                  ),
                  childCount: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 173 / 329,
                ),
              ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
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