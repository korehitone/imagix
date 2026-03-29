import 'package:flutter/material.dart';

// import '../../core/theme/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_image_card.dart';

class CollectionsPage extends StatefulWidget {
  final String collectionName;

  const CollectionsPage({
    super.key,
    this.collectionName = 'Collections Name',
  });

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
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
                      widget.collectionName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Edit icon
                  Padding(
                    padding: const EdgeInsets.only(right: 4), // ← nudge left to align with card
                    child: GestureDetector(
                      onTap: () {
                        // TODO: edit collection name
                      },
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Grid
              Expanded(
                child: GridView.builder(
                  itemCount: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 16), // ← justified left/right
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16, // ← gap between columns
                    mainAxisSpacing: 16, // ← gap between rows
                    childAspectRatio: 173 / 330, // ← 285 image + 7 gap + 24 title row
                  ),
                  itemBuilder: (context, index) {
                    return AppDetails(
                      title: 'Title',
                      onTap: () {},
                      onMore: () {},
                    );
                  },
                ),
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