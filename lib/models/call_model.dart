enum CallType { audio, video }
enum CallStatus { incoming, outgoing, missed, ended, rejected }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatarUrl;
  final String receiverId;
  final String receiverName;
  final String receiverAvatarUrl;
  final CallType type;
  final CallStatus status;
  final DateTime timestamp;
  final int durationSeconds;

  const CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatarUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.type,
    required this.status,
    required this.timestamp,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatarUrl': callerAvatarUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatarUrl': receiverAvatarUrl,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerAvatarUrl: json['callerAvatarUrl'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverAvatarUrl: json['receiverAvatarUrl'] as String,
      type: CallType.values.byName(json['type'] as String? ?? 'audio'),
      status: CallStatus.values.byName(json['status'] as String? ?? 'ended'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }
}
