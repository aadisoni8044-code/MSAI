enum MessageType { text, image, video, audio, document, location, link }

enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSender;
  final List<String> reactions;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.read,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSender,
    this.reactions = const [],
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    String? mediaUrl,
    String? fileName,
    String? fileSize,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSender,
    List<String>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSender: replyToSender ?? this.replyToSender,
      reactions: reactions ?? this.reactions,
    );
  }
}
