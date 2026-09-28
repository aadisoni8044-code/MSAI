import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../models/status.dart';
import '../models/call.dart';
import '../models/community.dart';
import '../mock/mock_data.dart';

class MockService extends ChangeNotifier {
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;
  MockService._internal() {
    _chats = List.from(MockData.mockChats);
    _messagesMap = Map.from(MockData.mockMessages);
    _statuses = List.from(MockData.mockStatuses);
    _calls = List.from(MockData.mockCalls);
    _communities = List.from(MockData.mockCommunities);
    _users = List.from(MockData.mockUsers);
  }

  late List<Chat> _chats;
  late Map<String, List<Message>> _messagesMap;
  late List<UserStatus> _statuses;
  late List<Call> _calls;
  late List<Community> _communities;
  late List<User> _users;

  List<Chat> get chats => _chats;
  List<UserStatus> get statuses => _statuses;
  List<Call> get calls => _calls;
  List<Community> get communities => _communities;
  List<User> get users => _users;
  User get currentUser => MockData.currentUser;

  List<Message> getMessages(String chatId) {
    return _messagesMap[chatId] ?? [];
  }

  Chat? getChatById(String chatId) {
    try {
      return _chats.firstWhere((c) => c.id == chatId);
    } catch (_) {
      return null;
    }
  }

  void sendMessage(String chatId, String content, {MessageType type = MessageType.text, String? mediaUrl, String? fileName, String? fileSize, String? replyToId, String? replyToContent, String? replyToSenderName}) {
    final newMessage = Message(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
    );

    if (!_messagesMap.containsKey(chatId)) {
      _messagesMap[chatId] = [];
    }
    _messagesMap[chatId]!.add(newMessage);

    // Update chat last message
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(lastMessage: newMessage);
    }

    notifyListeners();
  }

  void addReaction(String chatId, String messageId, String emoji) {
    final messages = _messagesMap[chatId];
    if (messages != null) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final currentReactions = List<String>.from(messages[index].reactions);
        currentReactions.add(emoji);
        messages[index] = messages[index].copyWith(reactions: currentReactions);
        notifyListeners();
      }
    }
  }

  void deleteMessage(String chatId, String messageId) {
    final messages = _messagesMap[chatId];
    if (messages != null) {
      messages.removeWhere((m) => m.id == messageId);
      if (messages.isNotEmpty) {
        final index = _chats.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          _chats[index] = _chats[index].copyWith(lastMessage: messages.last);
        }
      }
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

  Chat createOrGetChatWithUser(User user) {
    final existingIndex = _chats.indexWhere((c) => !c.isGroup && c.name == user.name);
    if (existingIndex != -1) {
      return _chats[existingIndex];
    }

    final newChat = Chat(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: user.name,
      avatarUrl: user.avatarUrl,
      isGroup: false,
      isOnline: user.isOnline,
    );

    _chats.insert(0, newChat);
    _messagesMap[newChat.id] = [];
    notifyListeners();
    return newChat;
  }

  Chat createGroupChat(String groupName, List<String> memberUserIds) {
    final newGroup = Chat(
      id: 'cg_${DateTime.now().millisecondsSinceEpoch}',
      name: groupName,
      avatarUrl: 'https://picsum.photos/150/150?random=${DateTime.now().second}',
      isGroup: true,
      memberIds: ['user_me', ...memberUserIds],
      groupDescription: 'Group created on ZipGram social platform.',
    );

    _chats.insert(0, newGroup);
    _messagesMap[newGroup.id] = [
      Message(
        id: 'm_init_${DateTime.now().millisecondsSinceEpoch}',
        chatId: newGroup.id,
        senderId: currentUser.id,
        senderName: currentUser.name,
        content: 'Group "${groupName}" created.',
        timestamp: DateTime.now(),
      )
    ];
    notifyListeners();
    return newGroup;
  }
}
