import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/mock_service.dart';
import '../../widgets/call_tile.dart';
import 'call_active_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final MockService _mockService = MockService();

  @override
  Widget build(BuildContext context) {
    final calls = _mockService.calls;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add_call), onPressed: () {}),
        ],
      ),
      body: calls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.phone_missed_rounded, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('No call history', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: calls.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final call = calls[index];
                return CallTile(
                  call: call,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallActiveScreen(
                          userName: call.userName,
                          userAvatar: call.userAvatar,
                          isVideo: call.type == CallType.video,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final firstUser = _mockService.users.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CallActiveScreen(
                userName: firstUser.name,
                userAvatar: firstUser.avatarUrl,
                isVideo: false,
              ),
            ),
          );
        },
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
