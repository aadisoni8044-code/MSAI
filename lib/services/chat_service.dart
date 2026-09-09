import '../models/chat.dart';
import '../models/group.dart';

abstract class ChatService {
  Future<List<Chat>> getChats(String userId);
  Future<Chat> createOneToOneChat(String userId, String peerUserId);
  Future<Group> createGroupChat({
    required String name,
    required String description,
    required List<String> memberIds,
    required String creatorId,
  });
  Future<void> pinChat(String chatId, bool isPinned);
  Future<void> muteChat(String chatId, bool isMuted);
  Future<void> archiveChat(String chatId, bool isArchived);
  Future<void> leaveGroup(String groupId, String userId);
  Future<void> updateGroupInfo(Group group);
}

class ApiChatService implements ChatService {
  final List<Chat> _chats = [];

  @override
  Future<List<Chat>> getChats(String userId) async {
    return _chats;
  }

  @override
  Future<Chat> createOneToOneChat(String userId, String peerUserId) async {
    final chat = Chat(
      id: 'chat_${userId}_$peerUserId',
      name: 'Chat User',
      participantIds: [userId, peerUserId],
      updatedAt: DateTime.now(),
    );
    _chats.add(chat);
    return chat;
  }

  @override
  Future<Group> createGroupChat({
    required String name,
    required String description,
    required List<String> memberIds,
    required String creatorId,
  }) async {
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final group = Group(
      id: groupId,
      name: name,
      description: description,
      createdBy: creatorId,
      createdAt: DateTime.now(),
      memberIds: memberIds,
      adminIds: [creatorId],
    );

    final chat = Chat(
      id: groupId,
      name: name,
      isGroup: true,
      participantIds: memberIds,
      updatedAt: DateTime.now(),
    );
    _chats.add(chat);
    return group;
  }

  @override
  Future<void> pinChat(String chatId, bool isPinned) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isPinned: isPinned);
    }
  }

  @override
  Future<void> muteChat(String chatId, bool isMuted) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isMuted: isMuted);
    }
  }

  @override
  Future<void> archiveChat(String chatId, bool isArchived) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(isArchived: isArchived);
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    _chats.removeWhere((c) => c.id == groupId);
  }

  @override
  Future<void> updateGroupInfo(Group group) async {
    final index = _chats.indexWhere((c) => c.id == group.id);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(name: group.name);
    }
  }
}
