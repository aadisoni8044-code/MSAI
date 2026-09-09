import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../repositories/chat_repository.dart';
import '../core/services/network_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final NetworkService _networkService;

  List<ChatRoomModel> _chatRooms = [];
  final Map<String, List<ChatMessageModel>> _roomMessages = {};
  final List<String> _selectedMessageIds = [];
  final Map<String, bool> _typingStatus = {};
  bool _isLoading = false;
  String? _errorMessage;

  ChatProvider(this._chatRepository, this._networkService) {
    loadChatRooms();
  }

  List<ChatRoomModel> get chatRooms => _chatRooms;
  List<String> get selectedMessageIds => _selectedMessageIds;
  bool get isMultiSelecting => _selectedMessageIds.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isTyping(String chatRoomId) => _typingStatus[chatRoomId] ?? false;

  int get totalUnreadCount {
    return _chatRooms.fold(0, (sum, room) => sum + room.unreadCount);
  }

  Future<void> loadChatRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _chatRooms = await _chatRepository.getChatRooms();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ChatMessageModel> getMessagesForRoom(String roomId) {
    return _roomMessages[roomId] ?? [];
  }

  Future<void> loadMessages(String chatRoomId) async {
    try {
      final msgs = await _chatRepository.getMessages(chatRoomId);
      _roomMessages[chatRoomId] = msgs;
      await _chatRepository.markChatAsRead(chatRoomId);
      final idx = _chatRooms.indexWhere((r) => r.id == chatRoomId);
      if (idx != -1) {
        _chatRooms[idx] = _chatRooms[idx].copyWith(unreadCount: 0);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<ChatRoomModel> getOrCreateDirectChat(String participantId) async {
    return await _chatRepository.getOrCreateDirectChat(participantId);
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? audioDurationSeconds,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
  }) async {
    final isOnline = _networkService.isConnected;
    final tempMsg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      chatRoomId: chatRoomId,
      content: content,
      type: type,
      status: isOnline ? MessageStatus.sending : MessageStatus.sending,
      timestamp: DateTime.now(),
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      audioDurationSeconds: audioDurationSeconds,
      latitude: latitude,
      longitude: longitude,
      contactName: contactName,
      contactPhone: contactPhone,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
    );

    if (!_roomMessages.containsKey(chatRoomId)) {
      _roomMessages[chatRoomId] = [];
    }
    _roomMessages[chatRoomId]!.add(tempMsg);
    notifyListeners();

    try {
      final sentMsg = await _chatRepository.sendMessage(tempMsg);
      final list = _roomMessages[chatRoomId]!;
      final idx = list.indexWhere((m) => m.id == tempMsg.id);
      if (idx != -1) {
        list[idx] = sentMsg;
      }
      await loadChatRooms();
    } catch (e) {
      final list = _roomMessages[chatRoomId]!;
      final idx = list.indexWhere((m) => m.id == tempMsg.id);
      if (idx != -1) {
        list[idx] = tempMsg.copyWith(status: MessageStatus.failed);
      }
      notifyListeners();
    }
  }

  Future<void> editMessage(String chatRoomId, String messageId, String newContent) async {
    try {
      final updated = await _chatRepository.editMessage(messageId, newContent);
      final list = _roomMessages[chatRoomId];
      if (list != null) {
        final idx = list.indexWhere((m) => m.id == messageId);
        if (idx != -1) {
          list[idx] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSelectedMessages(String chatRoomId) async {
    if (_selectedMessageIds.isEmpty) return;
    try {
      await _chatRepository.deleteMessages(_selectedMessageIds);
      _roomMessages[chatRoomId]?.removeWhere((m) => _selectedMessageIds.contains(m.id));
      _selectedMessageIds.clear();
      await loadChatRooms();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleStarSelectedMessages(String chatRoomId) async {
    if (_selectedMessageIds.isEmpty) return;
    try {
      await _chatRepository.toggleStarMessages(_selectedMessageIds);
      final list = _roomMessages[chatRoomId];
      if (list != null) {
        for (var i = 0; i < list.length; i++) {
          if (_selectedMessageIds.contains(list[i].id)) {
            list[i] = list[i].copyWith(isStarred: !list[i].isStarred);
          }
        }
      }
      _selectedMessageIds.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void toggleMessageSelection(String messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }
    notifyListeners();
  }

  void clearMessageSelection() {
    _selectedMessageIds.clear();
    notifyListeners();
  }

  void setTyping(String chatRoomId, bool isTyping) {
    _typingStatus[chatRoomId] = isTyping;
    notifyListeners();
  }
}
