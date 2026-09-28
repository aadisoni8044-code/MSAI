class User {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String about;
  final bool isOnline;
  final DateTime? lastSeen;
  final String phoneNumber;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.about,
    this.isOnline = false,
    this.lastSeen,
    required this.phoneNumber,
  });
}
