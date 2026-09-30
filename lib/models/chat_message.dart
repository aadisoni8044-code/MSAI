enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToId;
  final String? replyToText;
  final String? reaction;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.replyToText,
    this.reaction,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'reaction': reaction,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      replyToId: json['replyToId'] as String?,
      replyToText: json['replyToText'] as String?,
      reaction: json['reaction'] as String?,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyToId,
    String? replyToText,
    String? reaction,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToId: replyToId ?? this.replyToId,
      replyToText: replyToText ?? this.replyToText,
      reaction: reaction ?? this.reaction,
    );
  }
}
