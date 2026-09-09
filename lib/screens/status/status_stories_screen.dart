import 'package:flutter/material.dart';
import '../../models/status_model.dart';
import '../../widgets/user_avatar.dart';
import '../../core/utils/date_formatter.dart';

class StatusStoriesScreen extends StatefulWidget {
  final StatusModel? statusModel;

  const StatusStoriesScreen({super.key, this.statusModel});

  @override
  State<StatusStoriesScreen> createState() => _StatusStoriesScreenState();
}

class _StatusStoriesScreenState extends State<StatusStoriesScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final status = widget.statusModel;

    if (status == null || status.items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text('No status available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final currentItem = status.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: currentItem.type == StatusType.text
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.teal.shade800,
                      child: Center(
                        child: Text(
                          currentItem.mediaUrl,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Image.network(
                      currentItem.mediaUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.white),
                      ),
                    ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: List.generate(status.items.length, (idx) {
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: idx <= _currentIndex ? Colors.white : Colors.white38,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      UserAvatar(avatarUrl: status.userAvatarUrl, name: status.userName, radius: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(
                            DateFormatter.formatTimestamp(currentItem.timestamp),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (currentItem.caption.isNotEmpty)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Text(
                  currentItem.caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black54),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentIndex > 0) {
                        setState(() => _currentIndex--);
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_currentIndex < status.items.length - 1) {
                        setState(() => _currentIndex++);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
