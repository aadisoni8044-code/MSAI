import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Friend> _friends = [];
  List<Message> _messages = [];
  String? _selectedFriendId;
  String _searchQuery = '';

  List<Friend> get friends {
    if (_searchQuery.isEmpty) return _friends;
    return _friends.where((f) =>
      f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      f.username.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<Message> get messages => _messages;
  String? get selectedFriendId => _selectedFriendId;

  ChatProvider() {
    _initChatData();
  }

  Future<void> _initChatData() async {
    await _storage.init();
    final savedMsgs = _storage.getMessages();

    if (savedMsgs.isNotEmpty) {
      _messages = savedMsgs;
    } else {
      _messages = [
        Message(
          id: 'msg_1',
          senderId: 'friend_1',
          receiverId: 'usr_me',
          content: 'Hey Alex! Did you check out the new camera filter on ZipPro? 📸',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isSeen: true,
        ),
        Message(
          id: 'msg_2',
          senderId: 'usr_me',
          receiverId: 'friend_1',
          content: 'Yeah! The color adjustments are super smooth 🔥',
          type: MessageType.text,
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isSeen: true,
        ),
        Message(
          id: 'msg_3',
          senderId: 'friend_2',
          receiverId: 'usr_me',
          content: 'Check out this sunset preview!',
          type: MessageType.image,
          mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isSeen: false,
        ),
      ];
      await _storage.saveMessages(_messages);
    }

    _friends = [
      Friend(
        id: 'friend_1',
        name: 'Sarah Connor',
        username: 'sarah_c',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        isOnline: true,
      ),
      Friend(
        id: 'friend_2',
        name: 'David Miller',
        username: 'dave_m',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
        isOnline: false,
        lastSeen: '10m ago',
      ),
      Friend(
        id: 'friend_3',
        name: 'Elena Rostova',
        username: 'elena_r',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
        isOnline: true,
        isTyping: true,
      ),
      Friend(
        id: 'friend_4',
        name: 'Marcus Vance',
        username: 'marcus_v',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80',
        isOnline: false,
        lastSeen: '2h ago',
      ),
    ];

    notifyListeners();
  }

  void selectFriend(String friendId) {
    _selectedFriendId = friendId;
    // Mark messages as seen
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].senderId == friendId && !_messages[i].isSeen) {
        _messages[i] = _messages[i].copyWith(isSeen: true);
      }
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Message> getConversation(String friendId) {
    return _messages.where((m) =>
      (m.senderId == 'usr_me' && m.receiverId == friendId) ||
      (m.senderId == friendId && m.receiverId == 'usr_me')
    ).toList();
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final msg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'usr_me',
      receiverId: receiverId,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      isSeen: false,
    );
    _messages.add(msg);
    notifyListeners();
    await _storage.saveMessages(_messages);

    // Simulate auto-reply after 2s
    _simulateReply(receiverId);
  }

  void _simulateReply(String friendId) {
    Future.delayed(const Duration(seconds: 2), () async {
      final replyMsg = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: friendId,
        receiverId: 'usr_me',
        content: 'Awesome shot! ZipPro looks so clean!',
        type: MessageType.text,
        timestamp: DateTime.now(),
        isSeen: _selectedFriendId == friendId,
      );
      _messages.add(replyMsg);
      notifyListeners();
      await _storage.saveMessages(_messages);
    });
  }

  Future<void> addReaction(String messageId, String reaction) async {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(
        reaction: _messages[idx].reaction == reaction ? null : reaction,
      );
      notifyListeners();
      await _storage.saveMessages(_messages);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
    await _storage.saveMessages(_messages);
  }
}
