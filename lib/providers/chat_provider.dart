import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String message;
  final String timestamp;
  final bool isSnap;
  final bool isOpened;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    required this.timestamp,
    this.isSnap = false,
    this.isOpened = false,
    this.isMe = false,
  });
}

class ChatConversation {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.messages,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'chat_1',
      name: 'CyberAura_99',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      lastMessage: 'New Snap received ⚡',
      time: '2m ago',
      unreadCount: 1,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'm1',
          senderName: 'CyberAura_99',
          senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
          message: 'Hey check out this new Cyberpunk filter on Zippro!',
          timestamp: '10:42 AM',
        ),
        ChatMessage(
          id: 'm2',
          senderName: 'CyberAura_99',
          senderAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
          message: 'New Snap received ⚡',
          timestamp: '10:44 AM',
          isSnap: true,
        ),
      ],
    ),
    ChatConversation(
      id: 'chat_2',
      name: 'NeonRider',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      lastMessage: 'Delivered • 15m ago',
      time: '15m ago',
      unreadCount: 0,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'm3',
          senderName: 'Me',
          senderAvatar: '',
          message: 'Did you see the Zippro Ultra filter glow?',
          timestamp: '10:30 AM',
          isMe: true,
        ),
      ],
    ),
    ChatConversation(
      id: 'chat_3',
      name: 'VaporPulse',
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      lastMessage: 'Opened • 1h ago',
      time: '1h ago',
      unreadCount: 0,
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'm4',
          senderName: 'VaporPulse',
          senderAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
          message: 'Sent a video snap',
          timestamp: '9:15 AM',
          isSnap: true,
          isOpened: true,
        ),
      ],
    ),
    ChatConversation(
      id: 'chat_4',
      name: 'GlitchMaster',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
      lastMessage: 'New Snap received 🎬',
      time: '3h ago',
      unreadCount: 2,
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'm5',
          senderName: 'GlitchMaster',
          senderAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
          message: 'Testing matrix rain filter on live stream',
          timestamp: '7:20 AM',
        ),
      ],
    ),
  ];

  List<ChatConversation> get conversations => _conversations;

  void sendMessage(String conversationId, String text, {bool isSnap = false}) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final msg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderName: 'Me',
        senderAvatar: '',
        message: text,
        timestamp: 'Just now',
        isMe: true,
        isSnap: isSnap,
      );
      _conversations[idx].messages.add(msg);
      notifyListeners();
    }
  }
}
