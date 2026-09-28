import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';
import 'community_details_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final MockService _mockService = MockService();

  @override
  Widget build(BuildContext context) {
    final communities = _mockService.communities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.group_add_rounded, color: AppColors.primary),
            ),
            title: const Text('New Community', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: const Text('Bring members together in topic-based groups', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            onTap: () {},
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Your Communities', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ...communities.map((comm) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.surface,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Avatar(imageUrl: comm.avatarUrl, radius: 24, isGroup: true),
                title: Text(comm.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${comm.groupCount} groups • ${comm.memberCount} members', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('📢 ${comm.latestAnnouncement}', style: const TextStyle(color: AppColors.primaryLight, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityDetailsScreen(community: comm),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
