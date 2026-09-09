import '../models/message.dart';
import '../services/message_service.dart';

class MessageRepository {
  final MessageService _messageService;

  MessageRepository({MessageService? messageService})
      : _messageService = messageService ?? ApiMessageService();

  Future<List<Message>> getMessages(String chatId) =>
      _messageService.getMessages(chatId);

  Future<Message> sendMessage(Message message) =>
      _messageService.sendMessage(message);

  Future<void> deleteMessage(String messageId) =>
      _messageService.deleteMessage(messageId);

  Future<void> toggleStarMessage(String messageId, bool isStarred) =>
      _messageService.starMessage(messageId, isStarred);

  Future<void> togglePinMessage(String messageId, bool isPinned) =>
      _messageService.pinMessage(messageId, isPinned);
}
