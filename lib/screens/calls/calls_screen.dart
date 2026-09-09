import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/call.dart';
import '../../services/call_service.dart';
import '../../widgets/user_avatar.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final CallService _callService = WebRtcCallService();
  List<CallModel> _callHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final history = await _callService.getCallHistory();
    if (history.isEmpty) {
      // Demo history for initial display
      history.addAll([
        CallModel(
          id: 'c1',
          callerId: 'usr_1',
          callerName: 'Aarav Sharma',
          receiverId: 'self',
          receiverName: 'Me',
          type: CallType.video,
          status: CallStatus.missed,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        CallModel(
          id: 'c2',
          callerId: 'self',
          callerName: 'Me',
          receiverId: 'usr_2',
          receiverName: 'Sofia Rodriguez',
          type: CallType.voice,
          status: CallStatus.connected,
          durationSeconds: 142,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
    }
    setState(() {
      _callHistory = history;
    });
  }

  Widget _buildCallIcon(CallStatus status) {
    if (status == CallStatus.missed) {
      return const Icon(Icons.call_missed, color: Colors.redAccent, size: 16);
    } else if (status == CallStatus.outgoing) {
      return const Icon(Icons.call_made, color: Colors.green, size: 16);
    }
    return const Icon(Icons.call_received, color: Colors.blue, size: 16);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _callHistory.length,
      itemBuilder: (ctx, index) {
        final call = _callHistory[index];
        final name = call.callerId == 'self' ? call.receiverName : call.callerName;

        return ListTile(
          leading: UserAvatar(name: name, radius: 24),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              _buildCallIcon(call.status),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, hh:mm a').format(call.timestamp),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              call.type == CallType.video ? Icons.videocam : Icons.call,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $name...')),
              );
            },
          ),
        );
      },
    );
  }
}
