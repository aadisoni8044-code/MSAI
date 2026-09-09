import '../models/group_model.dart';
import '../models/chat_message_model.dart';

abstract class GroupRepository {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String avatarUrl,
    required List<String> memberIds,
  });
  Future<GroupModel> addMembers(String groupId, List<String> memberIds);
  Future<GroupModel> removeMember(String groupId, String memberId);
  Future<GroupModel> updateGroupInfo({required String groupId, String? name, String? description, String? avatarUrl});
  Future<void> toggleMuteGroup(String groupId);
  Future<List<ChatMessageModel>> getGroupMessages(String groupId);
  Future<ChatMessageModel> sendGroupMessage(ChatMessageModel message);
}
