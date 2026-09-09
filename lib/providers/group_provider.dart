import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/chat_message_model.dart';
import '../repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  List<GroupModel> _groups = [];
  final Map<String, List<ChatMessageModel>> _groupMessages = {};
  bool _isLoading = false;
  String? _errorMessage;

  GroupProvider(this._groupRepository) {
    loadGroups();
  }

  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      _groups = await _groupRepository.getGroups();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ChatMessageModel> getMessagesForGroup(String groupId) {
    return _groupMessages[groupId] ?? [];
  }

  Future<void> loadGroupMessages(String groupId) async {
    try {
      final msgs = await _groupRepository.getGroupMessages(groupId);
      _groupMessages[groupId] = msgs;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<GroupModel?> createGroup({
    required String name,
    required String description,
    required String avatarUrl,
    required List<String> memberIds,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newGroup = await _groupRepository.createGroup(
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        memberIds: memberIds,
      );
      _groups.add(newGroup);
      return newGroup;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final tempMsg = ChatMessageModel(
      id: 'gmsg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: groupId,
      chatRoomId: groupId,
      content: content,
      type: type,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }
    _groupMessages[groupId]!.add(tempMsg);
    notifyListeners();

    try {
      await _groupRepository.sendGroupMessage(tempMsg);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleMuteGroup(String groupId) async {
    try {
      await _groupRepository.toggleMuteGroup(groupId);
      final idx = _groups.indexWhere((g) => g.id == groupId);
      if (idx != -1) {
        _groups[idx] = _groups[idx].copyWith(isMuted: !_groups[idx].isMuted);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
