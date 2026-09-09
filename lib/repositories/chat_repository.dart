import '../models/chat.dart';
import '../models/group.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository({ChatService? chatService})
      : _chatService = chatService ?? ApiChatService();

  Future<List<Chat>> getChats(String userId) => _chatService.getChats(userId);

  Future<Chat> createOneToOneChat(String userId, String peerUserId) =>
      _chatService.createOneToOneChat(userId, peerUserId);

  Future<Group> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
    required String creatorId,
  }) {
    return _chatService.createGroupChat(
      name: name,
      description: description,
      memberIds: memberIds,
      creatorId: creatorId,
    );
  }

  Future<void> togglePin(String chatId, bool isPinned) =>
      _chatService.pinChat(chatId, isPinned);

  Future<void> toggleMute(String chatId, bool isMuted) =>
      _chatService.muteChat(chatId, isMuted);

  Future<void> toggleArchive(String chatId, bool isArchived) =>
      _chatService.archiveChat(chatId, isArchived);

  Future<void> leaveGroup(String groupId, String userId) =>
      _chatService.leaveGroup(groupId, userId);
}
