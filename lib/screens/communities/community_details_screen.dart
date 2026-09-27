import 'package:flutter/material.dart';
import '../../models/community.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/avatar_widget.dart';

class CommunityDetailsScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailsScreen({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Info'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: AvatarWidget(
              imageUrl: community.avatarUrl,
              name: community.name,
              radius: 50,
              showOnlineIndicator: false,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              community.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${community.memberCount} Members • ${community.groupCount} Groups',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              community.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.campaign_rounded, color: AppColors.primaryBlue),
            title: const Text('Announcements', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(community.latestAnnouncement, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Groups in this community', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.group_rounded, color: Colors.white70),
            title: const Text('General Discussion', style: TextStyle(color: Colors.white)),
            subtitle: const Text('1,240 members', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.group_rounded, color: Colors.white70),
            title: const Text('Announcements & News', style: TextStyle(color: Colors.white)),
            subtitle: const Text('5,600 members', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
