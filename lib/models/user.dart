enum UserStatus { online, offline, away, busy }

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String statusMessage;
  final UserStatus status;
  final DateTime? lastSeen;
  final String phoneNumber;
  final String username;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.statusMessage = 'Hey there! I am using ZIPgram.',
    this.status = UserStatus.offline,
    this.lastSeen,
    this.phoneNumber = '+1 555-0199',
    required this.username,
  });
}
