enum MessageType {
  text,
  image,
  video,
  audio,
  voice,
  document,
  location,
  contact,
  emoji,
  reply,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? chatRoomId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final int? audioDurationSeconds;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderName;
  final bool isStarred;
  final bool isEdited;
  final bool isDeleted;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.chatRoomId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.audioDurationSeconds,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
    this.isStarred = false,
    this.isEdited = false,
    this.isDeleted = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? chatRoomId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    int? audioDurationSeconds,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
    bool? isStarred,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      isStarred: isStarred ?? this.isStarred,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatRoomId': chatRoomId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'audioDurationSeconds': audioDurationSeconds,
      'latitude': latitude,
      'longitude': longitude,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'replyToMessageId': replyToMessageId,
      'replyToContent': replyToContent,
      'replyToSenderName': replyToSenderName,
      'isStarred': isStarred,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      chatRoomId: json['chatRoomId'] as String?,
      content: json['content'] as String,
      type: MessageType.values.byName(json['type'] as String? ?? 'text'),
      status: MessageStatus.values.byName(json['status'] as String? ?? 'sent'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrl: json['mediaUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      audioDurationSeconds: json['audioDurationSeconds'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToContent: json['replyToContent'] as String?,
      replyToSenderName: json['replyToSenderName'] as String?,
      isStarred: json['isStarred'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}
