import 'dart:async';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final Map<String, List<ChatMessageModel>> _messages = {};
  final List<ChatRoomModel> _chatRooms = [];

  MockChatRepository() {
    _initSeedData();
  }

  void _initSeedData() {
    final now = DateTime.now();

    final userSarah = const UserModel(
      id: 'user_1',
      name: 'Sarah Connor',
      phoneNumber: '+1 555-0101',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      about: 'Living life one day at a time ✨',
      isOnline: true,
    );

    final userDavid = const UserModel(
      id: 'user_2',
      name: 'David Miller',
      phoneNumber: '+1 555-0102',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80',
      about: 'In a meeting 💼',
      isOnline: false,
    );

    final room1Id = 'chat_room_1';
    final room2Id = 'chat_room_2';

    final msg1 = ChatMessageModel(
      id: 'msg_1',
      senderId: 'user_1',
      receiverId: 'user_me',
      chatRoomId: room1Id,
      content: 'Hey Alex! Are we still on for the project review today?',
      type: MessageType.text,
      status: MessageStatus.read,
      timestamp: now.subtract(const Duration(minutes: 30)),
    );

    final msg2 = ChatMessageModel(
      id: 'msg_2',
      senderId: 'user_me',
      receiverId: 'user_1',
      chatRoomId: room1Id,
      content: 'Yes! Everything is ready. Let us meet at 4 PM.',
      type: MessageType.text,
      status: MessageStatus.read,
      timestamp: now.subtract(const Duration(minutes: 25)),
    );

    final msg3 = ChatMessageModel(
      id: 'msg_3',
      senderId: 'user_1',
      receiverId: 'user_me',
      chatRoomId: room1Id,
      content: 'Awesome! See you then.',
      type: MessageType.text,
      status: MessageStatus.read,
      timestamp: now.subtract(const Duration(minutes: 20)),
    );

    _messages[room1Id] = [msg1, msg2, msg3];

    final msg4 = ChatMessageModel(
      id: 'msg_4',
      senderId: 'user_2',
      receiverId: 'user_me',
      chatRoomId: room2Id,
      content: 'Please check the design assets attached below.',
      type: MessageType.text,
      status: MessageStatus.delivered,
      timestamp: now.subtract(const Duration(hours: 2)),
    );

    _messages[room2Id] = [msg4];

    _chatRooms.add(ChatRoomModel(
      id: room1Id,
      isGroup: false,
      name: userSarah.name,
      avatarUrl: userSarah.avatarUrl,
      participantIds: ['user_me', 'user_1'],
      participants: [userSarah],
      lastMessage: msg3,
      unreadCount: 0,
      updatedAt: msg3.timestamp,
    ));

    _chatRooms.add(ChatRoomModel(
      id: room2Id,
      isGroup: false,
      name: userDavid.name,
      avatarUrl: userDavid.avatarUrl,
      participantIds: ['user_me', 'user_2'],
      participants: [userDavid],
      lastMessage: msg4,
      unreadCount: 1,
      updatedAt: msg4.timestamp,
    ));
  }

  @override
  Future<List<ChatRoomModel>> getChatRooms() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _chatRooms.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.from(_chatRooms);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_messages[chatRoomId] ?? []);
  }

  @override
  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final roomId = message.chatRoomId ?? 'chat_room_1';
    final sentMessage = message.copyWith(status: MessageStatus.sent);

    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(sentMessage);

    final roomIdx = _chatRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      _chatRooms[roomIdx] = _chatRooms[roomIdx].copyWith(
        lastMessage: sentMessage,
        updatedAt: sentMessage.timestamp,
      );
    }

    return sentMessage;
  }

  @override
  Future<ChatMessageModel> editMessage(String messageId, String newContent) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var roomId in _messages.keys) {
      final list = _messages[roomId]!;
      final idx = list.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        final updated = list[idx].copyWith(content: newContent, isEdited: true);
        list[idx] = updated;
        return updated;
      }
    }
    throw Exception('Message not found');
  }

  @override
  Future<void> deleteMessages(List<String> messageIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var roomId in _messages.keys) {
      _messages[roomId]!.removeWhere((m) => messageIds.contains(m.id));
    }
  }

  @override
  Future<void> toggleStarMessages(List<String> messageIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (var roomId in _messages.keys) {
      final list = _messages[roomId]!;
      for (var i = 0; i < list.length; i++) {
        if (messageIds.contains(list[i].id)) {
          list[i] = list[i].copyWith(isStarred: !list[i].isStarred);
        }
      }
    }
  }

  @override
  Future<ChatRoomModel> getOrCreateDirectChat(String participantId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = _chatRooms.firstWhere(
      (r) => !r.isGroup && r.participantIds.contains(participantId),
      orElse: () => ChatRoomModel(
        id: 'chat_room_${DateTime.now().millisecondsSinceEpoch}',
        isGroup: false,
        name: 'Contact',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        participantIds: ['user_me', participantId],
        updatedAt: DateTime.now(),
      ),
    );

    if (!_chatRooms.contains(existing)) {
      _chatRooms.add(existing);
      _messages[existing.id] = [];
    }

    return existing;
  }

  @override
  Future<void> markChatAsRead(String chatRoomId) async {
    final roomIdx = _chatRooms.indexWhere((r) => r.id == chatRoomId);
    if (roomIdx != -1) {
      _chatRooms[roomIdx] = _chatRooms[roomIdx].copyWith(unreadCount: 0);
    }
  }

  @override
  Future<List<ChatMessageModel>> searchMessages(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    final results = <ChatMessageModel>[];
    for (var list in _messages.values) {
      for (var msg in list) {
        if (msg.content.toLowerCase().contains(lower)) {
          results.add(msg);
        }
      }
    }
    return results;
  }
}
