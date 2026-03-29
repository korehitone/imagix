import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_image_card.dart';
import '../widgets/app_profile_header.dart';

class ProfilePage extends StatefulWidget {
  final bool isOwnProfile;

  const ProfilePage({
    super.key,
    this.isOwnProfile = true,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 4;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              // Back Button
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),

              // Profile Header Widget
              AppProfileHeader(
                username: 'Username',
                bio: 'Bio Description',
                isOwnProfile: widget.isOwnProfile,
                onEditProfile: () {
                  // TODO: Navigate to edit profile
                },
              ),

              // Created / Saved Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                tabs: const [
                  Tab(text: 'Created'),
                  Tab(text: 'Saved'),
                ],
              ),

              const SizedBox(height: 16),

              // Grid Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Created Tab
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16, // Same as collections
                        mainAxisSpacing: 16,  // Same as collections
                        childAspectRatio: 173 / 329,
                      ),
                      itemBuilder: (context, index) {
                        return AppDetails(
                          title: 'Title',
                          onTap: () {},
                          onMore: () {},
                        );
                      },
                    ),

                    // Saved Tab
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 173 / 329,
                      ),
                      itemBuilder: (context, index) {
                        return AppDetails(
                          title: 'Title',
                          onTap: () {},
                          onMore: () {},
                        );
                      },
                    ),
                  ],
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