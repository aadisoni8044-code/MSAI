import 'message.dart';
import 'user.dart';

enum ChatType { individual, group }

class Chat {
  final String id;
  final ChatType type;
  final String name;
  final String avatarUrl;
  final User? participant;
  final List<User> groupMembers;
  final Message? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    required this.type,
    required this.name,
    required this.avatarUrl,
    this.participant,
    this.groupMembers = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.updatedAt,
  });

  Chat copyWith({
    String? id,
    ChatType? type,
    String? name,
    String? avatarUrl,
    User? participant,
    List<User>? groupMembers,
    Message? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    DateTime? updatedAt,
  }) {
    return Chat(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      participant: participant ?? this.participant,
      groupMembers: groupMembers ?? this.groupMembers,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
