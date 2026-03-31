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

  Widget _buildGrid() {
    return GridView.builder(
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
        );
      },
    );
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
          child: Column(
            children: [
              // Back Button — only shown when viewing another user's profile
              if (!widget.isOwnProfile)
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
                    _buildGrid(), // Created Tab
                    _buildGrid(), // Saved Tab
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