import '../models/status_model.dart';
import '../models/call_model.dart';

abstract class MediaRepository {
  Future<String> uploadMedia(String localPath, String mediaType);
}

abstract class StatusRepository {
  Future<List<StatusModel>> getStatuses();
  Future<void> addStatus(StatusItem item);
  Future<void> markStatusSeen(String statusId);
}

abstract class CallRepository {
  Future<List<CallModel>> getCallHistory();
  Future<CallModel> makeCall({required String receiverId, required CallType type});
  Future<void> clearCallHistory();
}
