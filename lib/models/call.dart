enum CallType { voice, video }
enum CallDirection { incoming, outgoing, missed }

class Call {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final CallType type;
  final CallDirection direction;
  final DateTime timestamp;
  final String duration;

  Call({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.duration = '00:00',
  });
}
