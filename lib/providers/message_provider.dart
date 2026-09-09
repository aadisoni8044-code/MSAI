import 'package:flutter/material.dart';
import '../models/message.dart';
import '../repositories/message_repository.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _messageRepository;

  final Map<String, List<Message>> _chatMessages = {};
  bool _isLoading = false;
  String? _errorMessage;

  MessageProvider({MessageRepository? messageRepository})
      : _messageRepository = messageRepository ?? MessageRepository();

  List<Message> getMessages(String chatId) => _chatMessages[chatId] ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final messages = await _messageRepository.getMessages(chatId);
      _chatMessages[chatId] = messages;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(Message message) async {
    final list = _chatMessages[message.chatId] ?? [];
    list.add(message);
    _chatMessages[message.chatId] = list;
    notifyListeners();

    try {
      final sent = await _messageRepository.sendMessage(message);
      final index = list.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        list[index] = sent;
        notifyListeners();
      }
    } catch (e) {
      final index = list.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        list[index] = list[index].copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final list = _chatMessages[chatId];
    if (list != null) {
      list.removeWhere((m) => m.id == messageId);
      notifyListeners();
      await _messageRepository.deleteMessage(messageId);
    }
  }

  Future<void> toggleStarMessage(String chatId, String messageId) async {
    final list = _chatMessages[chatId];
    if (list != null) {
      final index = list.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final newStarred = !list[index].isStarred;
        list[index] = list[index].copyWith(isStarred: newStarred);
        notifyListeners();
        await _messageRepository.toggleStarMessage(messageId, newStarred);
      }
    }
  }
}
