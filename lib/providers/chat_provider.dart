import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/group.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository;

  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  ChatProvider({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository();

  List<Chat> get chats {
    var result = _chats;
    if (_searchQuery.isNotEmpty) {
      result = result.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    result.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadChats(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _chats = await _chatRepository.getChats(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Chat> startOneToOneChat(String currentUserId, String peerUserId) async {
    final chat = await _chatRepository.createOneToOneChat(currentUserId, peerUserId);
    final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
    if (existingIndex == -1) {
      _chats.add(chat);
    }
    notifyListeners();
    return chat;
  }

  Future<Group> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
    required String creatorId,
  }) async {
    final group = await _chatRepository.createGroup(
      name: name,
      description: description,
      memberIds: memberIds,
      creatorId: creatorId,
    );
    await loadChats(creatorId);
    return group;
  }

  Future<void> togglePin(String chatId) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final newPinned = !_chats[index].isPinned;
      _chats[index] = _chats[index].copyWith(isPinned: newPinned);
      notifyListeners();
      await _chatRepository.togglePin(chatId, newPinned);
    }
  }

  Future<void> toggleMute(String chatId) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final newMuted = !_chats[index].isMuted;
      _chats[index] = _chats[index].copyWith(isMuted: newMuted);
      notifyListeners();
      await _chatRepository.toggleMute(chatId, newMuted);
    }
  }

  Future<void> toggleArchive(String chatId) async {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final newArchived = !_chats[index].isArchived;
      _chats[index] = _chats[index].copyWith(isArchived: newArchived);
      notifyListeners();
      await _chatRepository.toggleArchive(chatId, newArchived);
    }
  }
}
