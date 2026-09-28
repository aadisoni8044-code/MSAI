import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/community.dart';
import '../../widgets/avatar.dart';

class CommunityDetailsScreen extends StatelessWidget {
  final Community community;

  const CommunityDetailsScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(community.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Avatar(imageUrl: community.avatarUrl, radius: 48, isGroup: true),
            const SizedBox(height: 12),
            Text(community.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${community.memberCount} members • ${community.groupCount} groups',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                community.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text('Joined', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Announcements', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.campaign_rounded, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Latest Announcement', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(community.latestAnnouncement, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
