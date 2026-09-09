import 'chat_message_model.dart';
import 'user_model.dart';

class ChatRoomModel {
  final String id;
  final bool isGroup;
  final String name;
  final String avatarUrl;
  final List<String> participantIds;
  final List<UserModel> participants;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isMuted;

  const ChatRoomModel({
    required this.id,
    required this.isGroup,
    required this.name,
    required this.avatarUrl,
    required this.participantIds,
    this.participants = const [],
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isMuted = false,
  });

  ChatRoomModel copyWith({
    String? id,
    bool? isGroup,
    String? name,
    String? avatarUrl,
    List<String>? participantIds,
    List<UserModel>? participants,
    ChatMessageModel? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    bool? isMuted,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      isGroup: isGroup ?? this.isGroup,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      participantIds: participantIds ?? this.participantIds,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isGroup': isGroup,
      'name': name,
      'avatarUrl': avatarUrl,
      'participantIds': participantIds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
      'isMuted': isMuted,
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      isGroup: json['isGroup'] as bool,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      participants: (json['participants'] as List?)
              ?.map((p) => UserModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isMuted: json['isMuted'] as bool? ?? false,
    );
  }
}
