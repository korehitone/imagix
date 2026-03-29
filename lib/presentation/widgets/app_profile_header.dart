import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppProfileHeader extends StatelessWidget {
  final String username;
  final String bio;
  final String posts;
  final String followers;
  final String following;
  final String collections;
  final String? imageUrl;
  final VoidCallback? onEditProfile;

  const AppProfileHeader({
    super.key,
    this.username = 'Username',
    this.bio = 'Bio Description',
    this.posts = '6.7K',
    this.followers = '6.7K',
    this.following = '6.7K',
    this.collections = '6.7K',
    this.imageUrl,
    this.onEditProfile,
  });

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Profile Picture
        imageUrl != null
            ? CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(imageUrl!),
              )
            : Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 56,
                  color: Colors.black,
                ),
              ),

        const SizedBox(height: 12),

        // Username
        Text(
          username,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat(context, 'Posts', posts),
            _buildStat(context, 'Followers', followers),
            _buildStat(context, 'Following', following),
            _buildStat(context, 'Collections', collections),
          ],
        ),

        const SizedBox(height: 16),

        // Bio
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80), // ← taller bio box
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Text(
            bio,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),

        const SizedBox(height: 16),

        // Edit Profile Button
        SizedBox(
          width: 120,
          height: 44,
          child: ElevatedButton(
            onPressed: onEditProfile ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}