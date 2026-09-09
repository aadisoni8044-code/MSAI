import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/status.dart';
import '../../services/media_service.dart';
import '../../widgets/user_avatar.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final MediaService _mediaService = MediaService();

  final List<StatusModel> _myStatuses = [];
  final List<StatusModel> _recentStatuses = [
    StatusModel(
      id: 'st_1',
      userId: 'usr_1',
      userName: 'Aarav Sharma',
      type: StatusType.text,
      content: 'Launching new project today! 🚀',
      backgroundColorHex: '0xFF128C7E',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      expiresAt: DateTime.now().add(const Duration(hours: 22)),
    ),
    StatusModel(
      id: 'st_2',
      userId: 'usr_2',
      userName: 'Sofia Rodriguez',
      type: StatusType.image,
      content: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675',
      caption: 'Beautiful evening sunset 🌅',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(hours: 19)),
    ),
  ];

  void _createStatus(StatusType type) async {
    if (type == StatusType.text) {
      _showTextStatusDialog();
    } else {
      final file = await _mediaService.pickImageFromGallery();
      if (file != null) {
        setState(() {
          _myStatuses.add(
            StatusModel(
              id: 'st_${DateTime.now().millisecondsSinceEpoch}',
              userId: 'self',
              userName: 'My Status',
              type: StatusType.image,
              content: file.path,
              timestamp: DateTime.now(),
              expiresAt: DateTime.now().add(const Duration(hours: 24)),
            ),
          );
        });
      }
    }
  }

  void _showTextStatusDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text Status'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type a status...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _myStatuses.add(
                    StatusModel(
                      id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'self',
                      userName: 'My Status',
                      type: StatusType.text,
                      content: controller.text.trim(),
                      timestamp: DateTime.now(),
                      expiresAt: DateTime.now().add(const Duration(hours: 24)),
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _openStatusViewer(StatusModel status) {
    showDialog(
      context: context,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(status.userName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (status.type == StatusType.text)
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppConstants.primaryColor,
                  child: Text(
                    status.content,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                )
              else
                Container(
                  color: Colors.grey[900],
                  height: 300,
                  width: double.infinity,
                  child: const Icon(Icons.image, size: 80, color: Colors.white70),
                ),
              if (status.caption != null) ...[
                const SizedBox(height: 16),
                Text(
                  status.caption!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Stack(
            children: [
              const UserAvatar(name: 'My Status', radius: 26),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppConstants.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          title: const Text('My Status', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            _myStatuses.isEmpty
                ? 'Tap to add status update'
                : '${_myStatuses.length} updates',
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () => _createStatus(StatusType.image),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _createStatus(StatusType.text),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent updates',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ..._recentStatuses.map((st) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppConstants.accentColor, width: 2),
              ),
              child: UserAvatar(name: st.userName, radius: 22),
            ),
            title: Text(st.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Today, ${st.timestamp.hour}:${st.timestamp.minute.toString().padLeft(2, '0')}'),
            onTap: () => _openStatusViewer(st),
          );
        }),
      ],
    );
  }
}
