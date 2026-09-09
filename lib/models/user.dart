class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatarUrl;
  final String about;
  final String username;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> blockedUserIds;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.avatarUrl = '',
    this.about = 'Hey there! I am using MSAI Chat.',
    this.username = '',
    this.isOnline = false,
    this.lastSeen,
    this.blockedUserIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'about': about,
      'username': username,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'blockedUserIds': blockedUserIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      about: json['about'] as String? ?? 'Hey there! I am using MSAI Chat.',
      username: json['username'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen'] as String) : null,
      blockedUserIds: List<String>.from(json['blockedUserIds'] as List? ?? []),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? about,
    String? username,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? blockedUserIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      about: about ?? this.about,
      username: username ?? this.username,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }
}
