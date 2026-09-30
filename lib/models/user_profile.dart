class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String avatar; // Avatar color or identifier
  final String bio;
  final String deviceName;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar = '0xFF0088CC',
    this.bio = 'Chatting nearby with ZIPGRAM',
    this.deviceName = 'ZIPGRAM Device',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatar': avatar,
      'bio': bio,
      'deviceName': deviceName,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatar: json['avatar'] as String? ?? '0xFF0088CC',
      bio: json['bio'] as String? ?? 'Chatting nearby with ZIPGRAM',
      deviceName: json['deviceName'] as String? ?? 'ZIPGRAM Device',
    );
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatar,
    String? bio,
    String? deviceName,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      deviceName: deviceName ?? this.deviceName,
    );
  }
}
