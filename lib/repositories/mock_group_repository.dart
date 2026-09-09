import 'dart:async';
import '../models/group_model.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import 'group_repository.dart';

class MockGroupRepository implements GroupRepository {
  final List<GroupModel> _groups = [];
  final Map<String, List<ChatMessageModel>> _groupMessages = {};

  MockGroupRepository() {
    _initSeedData();
  }

  void _initSeedData() {
    final now = DateTime.now();

    final userSarah = const UserModel(
      id: 'user_1',
      name: 'Sarah Connor',
      phoneNumber: '+1 555-0101',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      about: 'Living life one day at a time ✨',
      isOnline: true,
    );

    final userDavid = const UserModel(
      id: 'user_2',
      name: 'David Miller',
      phoneNumber: '+1 555-0102',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80',
      about: 'In a meeting 💼',
      isOnline: false,
    );

    final groupId = 'group_1';
    final group = GroupModel(
      id: groupId,
      name: 'Flutter Dev Community',
      description: 'Official group for mobile app discussions & updates.',
      avatarUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=300&q=80',
      adminId: 'user_me',
      memberIds: ['user_me', 'user_1', 'user_2'],
      members: [
        const UserModel(id: 'user_me', name: 'Alex Johnson', phoneNumber: '+1 555-0199', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80'),
        userSarah,
        userDavid,
      ],
      createdAt: now.subtract(const Duration(days: 30)),
    );

    _groups.add(group);

    _groupMessages[groupId] = [
      ChatMessageModel(
        id: 'gmsg_1',
        senderId: 'user_1',
        receiverId: groupId,
        chatRoomId: groupId,
        content: 'Welcome everyone to the official Flutter group!',
        type: MessageType.text,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      ChatMessageModel(
        id: 'gmsg_2',
        senderId: 'user_me',
        receiverId: groupId,
        chatRoomId: groupId,
        content: 'Glad to be here! Working on the new WhatsApp Dart app.',
        type: MessageType.text,
        status: MessageStatus.read,
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  @override
  Future<List<GroupModel>> getGroups() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_groups);
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String avatarUrl,
    required List<String> memberIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newGroup = GroupModel(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      avatarUrl: avatarUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=300&q=80'
          : avatarUrl,
      adminId: 'user_me',
      memberIds: ['user_me', ...memberIds],
      createdAt: DateTime.now(),
    );

    _groups.add(newGroup);
    _groupMessages[newGroup.id] = [];
    return newGroup;
  }

  @override
  Future<GroupModel> addMembers(String groupId, List<String> memberIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx != -1) {
      final updatedMemberIds = {..._groups[idx].memberIds, ...memberIds}.toList();
      _groups[idx] = _groups[idx].copyWith(memberIds: updatedMemberIds);
      return _groups[idx];
    }
    throw Exception('Group not found');
  }

  @override
  Future<GroupModel> removeMember(String groupId, String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx != -1) {
      final updatedMemberIds = List<String>.from(_groups[idx].memberIds)..remove(memberId);
      _groups[idx] = _groups[idx].copyWith(memberIds: updatedMemberIds);
      return _groups[idx];
    }
    throw Exception('Group not found');
  }

  @override
  Future<GroupModel> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx != -1) {
      _groups[idx] = _groups[idx].copyWith(
        name: name ?? _groups[idx].name,
        description: description ?? _groups[idx].description,
        avatarUrl: avatarUrl ?? _groups[idx].avatarUrl,
      );
      return _groups[idx];
    }
    throw Exception('Group not found');
  }

  @override
  Future<void> toggleMuteGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _groups.indexWhere((g) => g.id == groupId);
    if (idx != -1) {
      _groups[idx] = _groups[idx].copyWith(isMuted: !_groups[idx].isMuted);
    }
  }

  @override
  Future<List<ChatMessageModel>> getGroupMessages(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_groupMessages[groupId] ?? []);
  }

  @override
  Future<ChatMessageModel> sendGroupMessage(ChatMessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final groupId = message.chatRoomId ?? 'group_1';
    final sentMsg = message.copyWith(status: MessageStatus.sent);

    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }
    _groupMessages[groupId]!.add(sentMsg);
    return sentMsg;
  }
}
