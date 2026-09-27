import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/call_tile.dart';

class CallsView extends StatelessWidget {
  const CallsView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockService();

    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final calls = service.calls;

        if (calls.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.darkSurfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_rounded, size: 48, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No recent calls',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your recent audio and video calls will show up here.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.link_rounded, color: Colors.white, size: 24),
              ),
              title: const Text(
                'Create call link',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text(
                'Share a link for your ZIPgram call',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call link copied to clipboard!')),
                );
              },
            ),
            const Divider(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Recent',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            ...calls.map(
              (call) => CallTile(
                call: call,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.activeCall, arguments: call.userName);
                },
                onCallPressed: () {
                  Navigator.pushNamed(context, AppRoutes.activeCall, arguments: call.userName);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
