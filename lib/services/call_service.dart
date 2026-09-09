import '../models/call.dart';

abstract class CallService {
  Future<CallModel> initiateCall({
    required String receiverId,
    required String receiverName,
    required CallType type,
  });
  Future<void> answerCall(String callId);
  Future<void> endCall(String callId);
  Future<List<CallModel>> getCallHistory();
}

class WebRtcCallService implements CallService {
  final List<CallModel> _callHistory = [];

  @override
  Future<CallModel> initiateCall({
    required String receiverId,
    required String receiverName,
    required CallType type,
  }) async {
    final call = CallModel(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: 'self',
      callerName: 'Me',
      receiverId: receiverId,
      receiverName: receiverName,
      type: type,
      status: CallStatus.outgoing,
      timestamp: DateTime.now(),
    );
    _callHistory.insert(0, call);
    return call;
  }

  @override
  Future<void> answerCall(String callId) async {
    final index = _callHistory.indexWhere((c) => c.id == callId);
    if (index != -1) {
      _callHistory[index] = _callHistory[index].copyWith(status: CallStatus.connected);
    }
  }

  @override
  Future<void> endCall(String callId) async {
    final index = _callHistory.indexWhere((c) => c.id == callId);
    if (index != -1) {
      _callHistory[index] = _callHistory[index].copyWith(status: CallStatus.ended);
    }
  }

  @override
  Future<List<CallModel>> getCallHistory() async {
    return _callHistory;
  }
}
