import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/status_tile.dart';
import 'status_viewer_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final MockService _mockService = MockService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _mockService.currentUser;
    final statuses = _mockService.statuses;

    final recentStatuses = statuses.where((s) => !s.isViewed).toList();
    final viewedStatuses = statuses.where((s) => s.isViewed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Stack(
              children: [
                Avatar(imageUrl: currentUser.avatarUrl, radius: 26),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            title: const Text('My Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: const Text('Tap to add status update', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status creation prototype')),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Recent Updates', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          if (recentStatuses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No recent updates', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...recentStatuses.map((s) => StatusTile(
                  status: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StatusViewerScreen(status: s)),
                    );
                  },
                )),
          if (viewedStatuses.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Viewed Updates', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            ...viewedStatuses.map((s) => StatusTile(
                  status: s,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StatusViewerScreen(status: s)),
                    );
                  },
                )),
          ]
        ],
      ),
    );
  }
}
