import 'user_model.dart';

enum CallType { audio, video }
enum CallDirection { incoming, outgoing, missed }

class CallRecord {
  final String id;
  final User participant;
  final CallType type;
  final CallDirection direction;
  final DateTime timestamp;
  final Duration? duration;

  const CallRecord({
    required this.id,
    required this.participant,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.duration,
  });
}
