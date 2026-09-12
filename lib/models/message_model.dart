enum MessageStatus { sending, sent, delivered, read }
enum MessageType { text, image, voice, attachment }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? attachmentName;
  final String? attachmentSize;
  final Duration? voiceDuration;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.read,
    required this.timestamp,
    this.attachmentName,
    this.attachmentSize,
    this.voiceDuration,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? attachmentName,
    String? attachmentSize,
    Duration? voiceDuration,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      voiceDuration: voiceDuration ?? this.voiceDuration,
    );
  }
}
