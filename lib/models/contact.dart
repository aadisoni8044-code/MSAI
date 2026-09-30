class Contact {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isNearby;
  final bool isConnected;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  Contact({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isNearby = false,
    this.isConnected = false,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isNearby': isNearby,
      'isConnected': isConnected,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isNearby: json['isNearby'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Contact copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isNearby,
    bool? isConnected,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isNearby: isNearby ?? this.isNearby,
      isConnected: isConnected ?? this.isConnected,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
