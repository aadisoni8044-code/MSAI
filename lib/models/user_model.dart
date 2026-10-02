class User {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final List<String> savedMediaIds;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    List<String>? savedMediaIds,
  }) : savedMediaIds = savedMediaIds ?? [];

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    List<String>? savedMediaIds,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      savedMediaIds: savedMediaIds ?? List.from(this.savedMediaIds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'savedMediaIds': savedMediaIds,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      savedMediaIds: (json['savedMediaIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Friend {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final String lastSeen;
  final bool isTyping;

  Friend({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.isOnline = false,
    this.lastSeen = 'Recently',
    this.isTyping = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'isTyping': isTyping,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] as String? ?? 'Recently',
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }
}
