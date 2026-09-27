import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/status.dart';
import '../models/call.dart';
import '../models/community.dart';
import '../mock/mock_data.dart';

class MockService extends ChangeNotifier {
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;

  MockService._internal() {
    _chats = MockData.getInitialChats();
    _messages = MockData.getInitialMessages();
    _statuses = MockData.getInitialStatuses();
    _calls = MockData.getInitialCalls();
    _communities = MockData.getInitialCommunities();
  }

  late List<Chat> _chats;
  late Map<String, List<Message>> _messages;
  late List<Status> _statuses;
  late List<Call> _calls;
  late List<Community> _communities;

  User get currentUser => MockData.currentUser;
  List<User> get allUsers => MockData.mockUsers;
  List<Chat> get chats => List.unmodifiable(_chats);
  List<Status> get statuses => List.unmodifiable(_statuses);
  List<Call> get calls => List.unmodifiable(_calls);
  List<Community> get communities => List.unmodifiable(_communities);

  List<Message> getMessagesForChat(String chatId) {
    return _messages[chatId] ?? [];
  }

  void sendMessage({
    required String chatId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? fileName,
    String? fileSize,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSender,
  }) {
    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser.id,
      senderName: currentUser.name,
      text: text,
      timestamp: DateTime.now(),
      type: type,
      status: MessageStatus.sent,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSender: replyToSender,
    );

    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(newMessage);

    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: newMessage,
        updatedAt: DateTime.now(),
      );
    }

    notifyListeners();

    _simulateReply(chatId);
  }

  void _simulateReply(String chatId) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_messages.containsKey(chatId)) return;

    final chat = _chats.firstWhere((c) => c.id == chatId, orElse: () => _chats.first);
    final replySender = chat.type == ChatType.individual
        ? (chat.participant ?? MockData.mockUsers[0])
        : MockData.mockUsers[1];

    final replyMsg = Message(
      id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
      senderId: replySender.id,
      senderName: replySender.name,
      text: 'Got it! ZIPgram messaging is super smooth 👌',
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );

    _messages[chatId]!.add(replyMsg);

    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: replyMsg,
        updatedAt: DateTime.now(),
      );
    }

    notifyListeners();
  }

  void addReaction(String chatId, String messageId, String emoji) {
    if (!_messages.containsKey(chatId)) return;
    final list = _messages[chatId]!;
    final index = list.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = list[index];
      final currentReactions = List<String>.from(msg.reactions);
      if (currentReactions.contains(emoji)) {
        currentReactions.remove(emoji);
      } else {
        currentReactions.add(emoji);
      }
      list[index] = msg.copyWith(reactions: currentReactions);
      notifyListeners();
    }
  }

  void deleteMessage(String chatId, String messageId) {
    if (!_messages.containsKey(chatId)) return;
    _messages[chatId]!.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  void togglePinChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isPinned: !_chats[index].isPinned);
      notifyListeners();
    }
  }

  void toggleMuteChat(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isMuted: !_chats[index].isMuted);
      notifyListeners();
    }
  }

  Chat startOrCreateChatWithUser(User user) {
    final existing = _chats.firstWhere(
      (c) => c.type == ChatType.individual && c.participant?.id == user.id,
      orElse: () {
        final newChat = Chat(
          id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
          type: ChatType.individual,
          name: user.name,
          avatarUrl: user.avatarUrl,
          participant: user,
          updatedAt: DateTime.now(),
        );
        _chats.insert(0, newChat);
        _messages[newChat.id] = [];
        return newChat;
      },
    );
    notifyListeners();
    return existing;
  }

  Chat createGroupChat(String name, List<User> members) {
    final newGroup = Chat(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      type: ChatType.group,
      name: name,
      avatarUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
      groupMembers: [currentUser, ...members],
      updatedAt: DateTime.now(),
      lastMessage: Message(
        id: 'group_init',
        senderId: currentUser.id,
        senderName: currentUser.name,
        text: 'Group "$name" created',
        timestamp: DateTime.now(),
      ),
    );
    _chats.insert(0, newGroup);
    _messages[newGroup.id] = [
      Message(
        id: 'msg_welcome',
        senderId: currentUser.id,
        senderName: currentUser.name,
        text: 'Group created. Start sending messages!',
        timestamp: DateTime.now(),
      )
    ];
    notifyListeners();
    return newGroup;
  }
}
