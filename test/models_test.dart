import 'package:flutter_test/flutter_test.dart';
import 'package:msai_chat/models/user.dart';
import 'package:msai_chat/models/message.dart';
import 'package:msai_chat/models/chat.dart';

void main() {
  group('User Model Tests', () {
    test('User serialization and copyWith', () {
      final user = User(
        id: 'u1',
        name: 'Test User',
        phone: '+1234567890',
        email: 'test@example.com',
      );

      final json = user.toJson();
      expect(json['id'], 'u1');
      expect(json['name'], 'Test User');

      final userFromJson = User.fromJson(json);
      expect(userFromJson.id, user.id);
      expect(userFromJson.email, user.email);

      final updatedUser = user.copyWith(name: 'Updated Name');
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.id, 'u1');
    });
  });

  group('Message Model Tests', () {
    test('Message serialization and copyWith', () {
      final msg = Message(
        id: 'm1',
        chatId: 'c1',
        senderId: 'u1',
        content: 'Hello World',
        timestamp: DateTime(2026, 1, 1),
      );

      final json = msg.toJson();
      expect(json['id'], 'm1');
      expect(json['content'], 'Hello World');

      final msgFromJson = Message.fromJson(json);
      expect(msgFromJson.id, msg.id);
      expect(msgFromJson.type, MessageType.text);

      final starredMsg = msg.copyWith(isStarred: true);
      expect(starredMsg.isStarred, true);
    });
  });

  group('Chat Model Tests', () {
    test('Chat serialization and copyWith', () {
      final chat = Chat(
        id: 'c1',
        name: 'Group Chat',
        isGroup: true,
        participantIds: ['u1', 'u2'],
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = chat.toJson();
      expect(json['id'], 'c1');
      expect(json['isGroup'], true);

      final chatFromJson = Chat.fromJson(json);
      expect(chatFromJson.name, 'Group Chat');

      final pinnedChat = chat.copyWith(isPinned: true);
      expect(pinnedChat.isPinned, true);
    });
  });
}
