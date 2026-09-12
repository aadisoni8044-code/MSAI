import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService extends ChangeNotifier {
  final Map<String, List<Message>> _messagesByChatId = {};
  List<Chat> _chats = [];

  ChatService() {
    _initDemoData();
  }

  List<Chat> get chats => _chats;

  List<Message> getMessagesForChat(String chatId) {
    return _messagesByChatId[chatId] ?? [];
  }

  void _initDemoData() {
    final now = DateTime.now();

    final user1 = User(
      id: 'user_1',
      name: 'Sophia Vance',
      username: 'sophiav',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      bio: 'Design lead @ ZIPGRAM | Tech enthusiast',
      phone: '+1 (555) 234-5678',
      status: UserStatus.online,
      lastSeen: now,
    );

    final user2 = User(
      id: 'user_2',
      name: 'Liam Chen',
      username: 'liamc',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      bio: 'Mobile Dev & Flutter fan 🚀',
      phone: '+1 (555) 876-5432',
      status: UserStatus.online,
      lastSeen: now,
    );

    final user3 = User(
      id: 'user_3',
      name: 'Emma Watson',
      username: 'emmaw',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      bio: 'Coffee, Code & Creativity ☕🎨',
      phone: '+1 (555) 345-6789',
      status: UserStatus.offline,
      lastSeen: now.subtract(const Duration(minutes: 42)),
    );

    final user4 = User(
      id: 'user_4',
      name: 'Marcus Vance',
      username: 'marcusv',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      bio: 'Product Strategist',
      phone: '+1 (555) 456-7890',
      status: UserStatus.away,
      lastSeen: now.subtract(const Duration(hours: 3)),
    );

    // Initial messages for Chat 1
    _messagesByChatId['chat_1'] = [
      Message(
        id: 'm1_1',
        chatId: 'chat_1',
        senderId: 'user_1',
        content: 'Hey Alex! Have you reviewed the new blue UI system for ZIPGRAM?',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'm1_2',
        chatId: 'chat_1',
        senderId: 'user_current',
        content: 'Yes! The deep navy background with vibrant electric blue accents looks incredible!',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'm1_3',
        chatId: 'chat_1',
        senderId: 'user_1',
        content: 'Awesome! I sent over the updated screen layout specs as an attachment.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: MessageType.attachment,
        attachmentName: 'ZIPGRAM_DesignSystem_v2.pdf',
        attachmentSize: '4.2 MB',
        status: MessageStatus.read,
      ),
      Message(
        id: 'm1_4',
        chatId: 'chat_1',
        senderId: 'user_1',
        content: 'Let me know what you think when you have a moment! 🚀',
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.read,
      ),
    ];

    // Initial messages for Chat 2
    _messagesByChatId['chat_2'] = [
      Message(
        id: 'm2_1',
        chatId: 'chat_2',
        senderId: 'user_current',
        content: 'Hey Liam, did the test suite for the Flutter app pass?',
        timestamp: now.subtract(const Duration(hours: 5)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'm2_2',
        chatId: 'chat_2',
        senderId: 'user_2',
        content: 'All green! 100% Flutter and Dart pure implementation.',
        timestamp: now.subtract(const Duration(hours: 4, minutes: 50)),
        status: MessageStatus.read,
      ),
      Message(
        id: 'm2_3',
        chatId: 'chat_2',
        senderId: 'user_2',
        content: 'Voice note preview for call testing',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: MessageType.voice,
        voiceDuration: const Duration(seconds: 18),
        status: MessageStatus.read,
      ),
    ];

    // Initial messages for Chat 3
    _messagesByChatId['chat_3'] = [
      Message(
        id: 'm3_1',
        chatId: 'chat_3',
        senderId: 'user_3',
        content: 'Catching up for coffee this weekend?',
        timestamp: now.subtract(const Duration(days: 1)),
        status: MessageStatus.read,
      ),
    ];

    // Initial messages for Chat 4
    _messagesByChatId['chat_4'] = [
      Message(
        id: 'm4_1',
        chatId: 'chat_4',
        senderId: 'user_4',
        content: 'Check out this screenshot from the demo build',
        timestamp: now.subtract(const Duration(days: 2)),
        type: MessageType.image,
        attachmentName: 'preview_screen.png',
        status: MessageStatus.read,
      ),
    ];

    _chats = [
      Chat(
        id: 'chat_1',
        participant: user1,
        lastMessage: _messagesByChatId['chat_1']!.last,
        unreadCount: 1,
        isPinned: true,
      ),
      Chat(
        id: 'chat_2',
        participant: user2,
        lastMessage: _messagesByChatId['chat_2']!.last,
        unreadCount: 0,
        isPinned: true,
      ),
      Chat(
        id: 'chat_3',
        participant: user3,
        lastMessage: _messagesByChatId['chat_3']!.last,
        unreadCount: 0,
        isPinned: false,
      ),
      Chat(
        id: 'chat_4',
        participant: user4,
        lastMessage: _messagesByChatId['chat_4']!.last,
        unreadCount: 0,
        isPinned: false,
      ),
    ];
  }

  void sendMessage({
    required String chatId,
    required String text,
    MessageType type = MessageType.text,
    String? attachmentName,
    String? attachmentSize,
    Duration? voiceDuration,
  }) {
    final now = DateTime.now();
    final newMsg = Message(
      id: 'msg_${now.millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'user_current',
      content: text,
      type: type,
      status: MessageStatus.sent,
      timestamp: now,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      voiceDuration: voiceDuration,
    );

    if (_messagesByChatId.containsKey(chatId)) {
      _messagesByChatId[chatId]!.add(newMsg);
    } else {
      _messagesByChatId[chatId] = [newMsg];
    }

    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(
        lastMessage: newMsg,
      );
    }

    notifyListeners();

    // Simulate auto reply after 1.5 seconds for interactive demo
    Future.delayed(const Duration(milliseconds: 1500), () {
      _receiveAutoReply(chatId);
    });
  }

  void _receiveAutoReply(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex == -1) return;

    final chat = _chats[chatIndex];
    final replyMsg = Message(
      id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: chat.participant.id,
      content: 'Got it! ZIPGRAM is super smooth and fast! 👍⚡',
      type: MessageType.text,
      status: MessageStatus.read,
      timestamp: DateTime.now(),
    );

    _messagesByChatId[chatId]?.add(replyMsg);
    _chats[chatIndex] = _chats[chatIndex].copyWith(
      lastMessage: replyMsg,
      unreadCount: _chats[chatIndex].unreadCount + 1,
    );

    notifyListeners();
  }

  void togglePinChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isPinned: !_chats[index].isPinned);
      notifyListeners();
    }
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1 && _chats[index].unreadCount > 0) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  Chat startNewChatWithUser(User user) {
    final existingIndex = _chats.indexWhere((c) => c.participant.id == user.id);
    if (existingIndex != -1) {
      return _chats[existingIndex];
    }

    final newChatId = 'chat_${DateTime.now().millisecondsSinceEpoch}';
    final newChat = Chat(
      id: newChatId,
      participant: user,
      lastMessage: Message(
        id: 'msg_init_$newChatId',
        chatId: newChatId,
        senderId: 'user_current',
        content: 'Hello ${user.name}!',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ),
    );

    _chats.insert(0, newChat);
    _messagesByChatId[newChatId] = [newChat.lastMessage!];
    notifyListeners();
    return newChat;
  }
}
