import 'message.dart';

class Chat {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isGroup;
  final bool isPinned;
  final bool isMuted;
  final int unreadCount;
  final Message? lastMessage;
  final bool isOnline;
  final List<String> memberIds;
  final String? groupDescription;

  Chat({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isGroup = false,
    this.isPinned = false,
    this.isMuted = false,
    this.unreadCount = 0,
    this.lastMessage,
    this.isOnline = false,
    this.memberIds = const [],
    this.groupDescription,
  });

  Chat copyWith({
    int? unreadCount,
    Message? lastMessage,
    bool? isPinned,
    bool? isMuted,
  }) {
    return Chat(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isGroup: isGroup,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      isOnline: isOnline,
      memberIds: memberIds,
      groupDescription: groupDescription,
    );
  }
}
