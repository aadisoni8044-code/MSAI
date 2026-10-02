import 'media_model.dart';

enum MessageType { text, image, video }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final String? mediaUrl;
  final DateTime timestamp;
  final bool isSeen;
  final String? reaction;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.timestamp,
    this.isSeen = false,
    this.reaction,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    String? mediaUrl,
    DateTime? timestamp,
    bool? isSeen,
    String? reaction,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      reaction: reaction ?? this.reaction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp.toIso8601String(),
      'isSeen': isSeen,
      'reaction': reaction,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      type: json['type'] == 'image'
          ? MessageType.image
          : json['type'] == 'video'
              ? MessageType.video
              : MessageType.text,
      mediaUrl: json['mediaUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSeen: json['isSeen'] as bool? ?? false,
      reaction: json['reaction'] as String?,
    );
  }
}
