import '../models/message.dart';

abstract class MessageService {
  Future<List<Message>> getMessages(String chatId);
  Future<Message> sendMessage(Message message);
  Future<void> updateMessageStatus(String messageId, MessageStatus status);
  Future<void> deleteMessage(String messageId);
  Future<void> starMessage(String messageId, bool isStarred);
  Future<void> pinMessage(String messageId, bool isPinned);
}

class ApiMessageService implements MessageService {
  final List<Message> _messages = [];

  @override
  Future<List<Message>> getMessages(String chatId) async {
    return _messages.where((m) => m.chatId == chatId).toList();
  }

  @override
  Future<Message> sendMessage(Message message) async {
    final sentMessage = message.copyWith(status: MessageStatus.sent);
    _messages.add(sentMessage);
    return sentMessage;
  }

  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(status: status);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
  }

  @override
  Future<void> starMessage(String messageId, bool isStarred) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isStarred: isStarred);
    }
  }

  @override
  Future<void> pinMessage(String messageId, bool isPinned) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(isPinned: isPinned);
    }
  }
}
