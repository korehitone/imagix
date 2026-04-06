import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppProfileHeader extends StatelessWidget {
  final String username;
  final String bio;
  final int posts;
  final int followers;
  final int following;
  final int collections;
  final String? imageUrl;
  final VoidCallback? onEditProfile;
  final VoidCallback? onFollow;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowAction;
  final bool isOwnProfile;
  final bool isFollowing;

  const AppProfileHeader({
    super.key,
    required this.username,
    required this.bio,
    required this.posts,
    required this.followers,
    required this.following,
    required this.collections,
    this.imageUrl,
    this.onEditProfile,
    this.onFollow,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onFollowAction,
    this.isOwnProfile = true,
    this.isFollowing = false,
  });

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              value, // value on top
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label, // label below
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Profile Picture
        imageUrl != null
            ? CircleAvatar(radius: 48, backgroundImage: NetworkImage(imageUrl!))
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
            _buildStat(context, 'Posts', "$posts", null),
            _buildStat(context, 'Followers', "$followers", onFollowersTap),
            _buildStat(context, 'Following', "$following", onFollowingTap),
            if (isOwnProfile)
              _buildStat(context, 'Collections', "$collections", null),
          ],
        ),

        const SizedBox(height: 16),

        // Bio
        // Container(
        //   width: double.infinity,
        //   constraints: const BoxConstraints(minHeight: 80),
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: AppColors.primary, width: 2),
        //   ),
        //   child: Text(
        //     bio,
        //     style: Theme.of(
        //       context,
        //     ).textTheme.bodyMedium?.copyWith(color: Colors.black),
        //   ),
        // ),
        if (bio.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft, // PAKSA KE KIRI
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                bio,
                textAlign: TextAlign.left, // TEKS RATA KIRI
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[800],
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Edit Profile Button
        // if (isOwnProfile)
        //   SizedBox(
        //     width: 120,
        //     height: 44,
        //     child: ElevatedButton(
        //       onPressed: onEditProfile ?? () {},
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: AppColors.primary,
        //         foregroundColor: Colors.white,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //         elevation: 0,
        //       ),
        //       child: Text(
        //         'Edit Profile',
        //         style: Theme.of(
        //           context,
        //         ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        //       ),
        //     ),
        //   ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: isOwnProfile
                ? _buildEditButton(context)
                : _buildFollowButton(context),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // Widget Tombol Edit
  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onEditProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Edit biasanya lebih soft warnanya
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.grey), // Kasih border tipis
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        'Edit Profile',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Widget Tombol Follow
  Widget _buildFollowButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Follow lebih mencolok
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        // TEKS: Ganti sesuai status
        isFollowing ? 'Unfollow' : 'Follow',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
