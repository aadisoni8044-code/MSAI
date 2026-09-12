import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';

class CallService extends ChangeNotifier {
  List<CallRecord> _callHistory = [];
  CallRecord? _activeCall;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoEnabled = true;

  CallService() {
    _initDemoData();
  }

  List<CallRecord> get callHistory => _callHistory;
  CallRecord? get activeCall => _activeCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isVideoEnabled => _isVideoEnabled;

  void _initDemoData() {
    final now = DateTime.now();

    final user1 = User(
      id: 'user_1',
      name: 'Sophia Vance',
      username: 'sophiav',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      bio: 'Design lead @ ZIPGRAM',
      phone: '+1 (555) 234-5678',
      status: UserStatus.online,
      lastSeen: now,
    );

    final user2 = User(
      id: 'user_2',
      name: 'Liam Chen',
      username: 'liamc',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      bio: 'Mobile Dev & Flutter fan 🚀',
      phone: '+1 (555) 876-5432',
      status: UserStatus.online,
      lastSeen: now,
    );

    final user3 = User(
      id: 'user_3',
      name: 'Emma Watson',
      username: 'emmaw',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      bio: 'Coffee, Code & Creativity',
      phone: '+1 (555) 345-6789',
      status: UserStatus.offline,
      lastSeen: now.subtract(const Duration(minutes: 42)),
    );

    _callHistory = [
      CallRecord(
        id: 'call_1',
        participant: user1,
        type: CallType.video,
        direction: CallDirection.incoming,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        duration: const Duration(minutes: 14, seconds: 22),
      ),
      CallRecord(
        id: 'call_2',
        participant: user2,
        type: CallType.audio,
        direction: CallDirection.outgoing,
        timestamp: now.subtract(const Duration(hours: 4)),
        duration: const Duration(minutes: 5, seconds: 10),
      ),
      CallRecord(
        id: 'call_3',
        participant: user3,
        type: CallType.video,
        direction: CallDirection.missed,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      CallRecord(
        id: 'call_4',
        participant: user1,
        type: CallType.audio,
        direction: CallDirection.outgoing,
        timestamp: now.subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 2, seconds: 45),
      ),
    ];
  }

  void startCall(User participant, CallType type) {
    _activeCall = CallRecord(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      participant: participant,
      type: type,
      direction: CallDirection.outgoing,
      timestamp: DateTime.now(),
    );
    _isMuted = false;
    _isSpeakerOn = true;
    _isVideoEnabled = type == CallType.video;

    _callHistory.insert(0, _activeCall!);
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoEnabled = !_isVideoEnabled;
    notifyListeners();
  }

  void endCall() {
    _activeCall = null;
    notifyListeners();
  }
}
