import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auxiliary_providers.dart';
import '../../models/call_model.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';

class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);

    if (callProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final calls = callProvider.calls;

    if (calls.isEmpty) {
      return const Center(
        child: Text('No recent calls', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.separated(
      itemCount: calls.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final call = calls[index];
        final isOutgoing = call.callerId == 'user_me';
        final peerName = isOutgoing ? call.receiverName : call.callerName;
        final peerAvatar = isOutgoing ? call.receiverAvatarUrl : call.callerAvatarUrl;

        return ListTile(
          leading: UserAvatar(
            avatarUrl: peerAvatar,
            name: peerName,
            radius: 26,
          ),
          title: Text(
            peerName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: call.status == CallStatus.missed ? AppColors.error : null,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                isOutgoing ? Icons.call_made : Icons.call_received,
                size: 16,
                color: call.status == CallStatus.missed
                    ? AppColors.error
                    : AppColors.accentGreen,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatTimestamp(call.timestamp),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              call.type == CallType.video ? Icons.videocam : Icons.call,
              color: AppColors.primaryTeal,
            ),
            onPressed: () {
              callProvider.makeCall(
                receiverId: isOutgoing ? call.receiverId : call.callerId,
                type: call.type,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $peerName...')),
              );
            },
          ),
        );
      },
    );
  }
}
