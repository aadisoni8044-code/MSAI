enum MessageType { text, image, video, voice, document, location }
enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderName;
  final List<String> reactions;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    required this.timestamp,
    this.status = MessageStatus.read,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
    this.reactions = const [],
  });

  Message copyWith({
    List<String>? reactions,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      timestamp: timestamp,
      status: status ?? this.status,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      reactions: reactions ?? this.reactions,
    );
  }
}
