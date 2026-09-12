import 'user_model.dart';
import 'message_model.dart';

class Chat {
  final String id;
  final User participant;
  final Message? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isTyping;

  const Chat({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isTyping = false,
  });

  Chat copyWith({
    String? id,
    User? participant,
    Message? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isTyping,
  }) {
    return Chat(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
