enum UserStatus { online, offline, away }

class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final String phone;
  final UserStatus status;
  final DateTime lastSeen;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.phone,
    this.status = UserStatus.offline,
    required this.lastSeen,
  });

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarUrl,
    String? bio,
    String? phone,
    UserStatus? status,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
