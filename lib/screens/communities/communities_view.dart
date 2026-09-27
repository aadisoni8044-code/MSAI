import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/community_card.dart';

class CommunitiesView extends StatelessWidget {
  const CommunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final communities = service.communities;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(38),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 28),
              ),
              title: const Text(
                'New Community',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text(
                'Organize related groups & send announcements',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create community dialog opened')),
                );
              },
            ),
            const Divider(height: 24),
            ...communities.map(
              (community) => CommunityCard(
                community: community,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.communityDetails, arguments: community);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
