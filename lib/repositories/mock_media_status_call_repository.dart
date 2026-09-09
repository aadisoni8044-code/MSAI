import 'dart:async';
import '../models/status_model.dart';
import '../models/call_model.dart';
import 'media_status_call_repository.dart';

class MockMediaRepository implements MediaRepository {
  @override
  Future<String> uploadMedia(String localPath, String mediaType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=600&q=80';
  }
}

class MockStatusRepository implements StatusRepository {
  final List<StatusModel> _statuses = [];

  MockStatusRepository() {
    _initSeedData();
  }

  void _initSeedData() {
    final now = DateTime.now();

    _statuses.add(StatusModel(
      id: 'status_me',
      userId: 'user_me',
      userName: 'My Status',
      userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      items: [
        StatusItem(
          id: 'item_me_1',
          type: StatusType.text,
          mediaUrl: 'Building WhatsApp Dart App 🚀',
          caption: 'Flutter is awesome!',
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
      ],
      updatedAt: now.subtract(const Duration(hours: 1)),
      isSeen: true,
    ));

    _statuses.add(StatusModel(
      id: 'status_1',
      userId: 'user_1',
      userName: 'Sarah Connor',
      userAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      items: [
        StatusItem(
          id: 'item_1_1',
          type: StatusType.image,
          mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
          caption: 'Beach sunset view! 🌅',
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
      ],
      updatedAt: now.subtract(const Duration(hours: 3)),
      isSeen: false,
    ));

    _statuses.add(StatusModel(
      id: 'status_2',
      userId: 'user_3',
      userName: 'Emma Watson',
      userAvatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=300&q=80',
      items: [
        StatusItem(
          id: 'item_2_1',
          type: StatusType.image,
          mediaUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
          caption: 'Coffee time ☕',
          timestamp: now.subtract(const Duration(hours: 6)),
        ),
      ],
      updatedAt: now.subtract(const Duration(hours: 6)),
      isSeen: true,
    ));
  }

  @override
  Future<List<StatusModel>> getStatuses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_statuses);
  }

  @override
  Future<void> addStatus(StatusItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _statuses.indexWhere((s) => s.userId == 'user_me');
    if (idx != -1) {
      final updatedItems = List<StatusItem>.from(_statuses[idx].items)..add(item);
      _statuses[idx] = _statuses[idx].copyWith(items: updatedItems, updatedAt: DateTime.now());
    } else {
      _statuses.add(StatusModel(
        id: 'status_me',
        userId: 'user_me',
        userName: 'My Status',
        userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
        items: [item],
        updatedAt: DateTime.now(),
        isSeen: true,
      ));
    }
  }

  @override
  Future<void> markStatusSeen(String statusId) async {
    final idx = _statuses.indexWhere((s) => s.id == statusId);
    if (idx != -1) {
      _statuses[idx] = _statuses[idx].copyWith(isSeen: true);
    }
  }
}

class MockCallRepository implements CallRepository {
  final List<CallModel> _calls = [];

  MockCallRepository() {
    _initSeedData();
  }

  void _initSeedData() {
    final now = DateTime.now();

    _calls.add(CallModel(
      id: 'call_1',
      callerId: 'user_1',
      callerName: 'Sarah Connor',
      callerAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      receiverId: 'user_me',
      receiverName: 'Alex Johnson',
      receiverAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      type: CallType.audio,
      status: CallStatus.incoming,
      timestamp: now.subtract(const Duration(hours: 1)),
      durationSeconds: 124,
    ));

    _calls.add(CallModel(
      id: 'call_2',
      callerId: 'user_me',
      callerName: 'Alex Johnson',
      callerAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      receiverId: 'user_2',
      receiverName: 'David Miller',
      receiverAvatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80',
      type: CallType.video,
      status: CallStatus.outgoing,
      timestamp: now.subtract(const Duration(hours: 4)),
      durationSeconds: 340,
    ));

    _calls.add(CallModel(
      id: 'call_3',
      callerId: 'user_3',
      callerName: 'Emma Watson',
      callerAvatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=300&q=80',
      receiverId: 'user_me',
      receiverName: 'Alex Johnson',
      receiverAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      type: CallType.audio,
      status: CallStatus.missed,
      timestamp: now.subtract(const Duration(days: 1)),
      durationSeconds: 0,
    ));
  }

  @override
  Future<List<CallModel>> getCallHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_calls);
  }

  @override
  Future<CallModel> makeCall({required String receiverId, required CallType type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newCall = CallModel(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: 'user_me',
      callerName: 'Alex Johnson',
      callerAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      receiverId: receiverId,
      receiverName: 'Contact',
      receiverAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      type: type,
      status: CallStatus.outgoing,
      timestamp: DateTime.now(),
      durationSeconds: 15,
    );
    _calls.insert(0, newCall);
    return newCall;
  }

  @override
  Future<void> clearCallHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _calls.clear();
  }
}
