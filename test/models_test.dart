import 'package:flutter_test/flutter_test.dart';
import '../lib/models/user_model.dart';
import '../lib/models/chat_message_model.dart';
import '../lib/models/chat_room_model.dart';

void main() {
  group('UserModel tests', () {
    test('UserModel JSON serialization and deserialization', () {
      final user = const UserModel(
        id: 'u1',
        name: 'Test User',
        phoneNumber: '+123456789',
        about: 'Testing Dart Models',
        isOnline: true,
      );

      final json = user.toJson();
      expect(json['id'], 'u1');
      expect(json['name'], 'Test User');

      final userFromJson = UserModel.fromJson(json);
      expect(userFromJson.id, user.id);
      expect(userFromJson.name, user.name);
      expect(userFromJson.phoneNumber, user.phoneNumber);
      expect(userFromJson.isOnline, true);
    });
  });

  group('ChatMessageModel tests', () {
    test('ChatMessageModel copyWith and status check', () {
      final now = DateTime.now();
      final msg = ChatMessageModel(
        id: 'msg_1',
        senderId: 's1',
        receiverId: 'r1',
        content: 'Hello World',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: now,
      );

      expect(msg.status, MessageStatus.sent);

      final readMsg = msg.copyWith(status: MessageStatus.read);
      expect(readMsg.status, MessageStatus.read);
      expect(readMsg.content, 'Hello World');
    });
  });

  group('ChatRoomModel tests', () {
    test('ChatRoomModel unread count and details', () {
      final room = ChatRoomModel(
        id: 'cr_1',
        isGroup: false,
        name: 'Room 1',
        avatarUrl: '',
        participantIds: ['u1', 'u2'],
        unreadCount: 3,
        updatedAt: DateTime.now(),
      );

      expect(room.unreadCount, 3);
      expect(room.isGroup, false);
    });
  });
}
