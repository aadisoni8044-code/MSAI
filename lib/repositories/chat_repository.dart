import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatRepository {
  Future<List<ChatRoomModel>> getChatRooms();
  Future<List<ChatMessageModel>> getMessages(String chatRoomId);
  Future<ChatMessageModel> sendMessage(ChatMessageModel message);
  Future<ChatMessageModel> editMessage(String messageId, String newContent);
  Future<void> deleteMessages(List<String> messageIds);
  Future<void> toggleStarMessages(List<String> messageIds);
  Future<ChatRoomModel> getOrCreateDirectChat(String participantId);
  Future<void> markChatAsRead(String chatRoomId);
  Future<List<ChatMessageModel>> searchMessages(String query);
}
