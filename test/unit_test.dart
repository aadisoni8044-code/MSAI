import 'package:flutter_test/flutter_test.dart';
import 'package:zippro/models/user_model.dart';
import 'package:zippro/models/message_model.dart';
import 'package:zippro/models/story_model.dart';
import 'package:zippro/models/media_model.dart';

void main() {
  group('ZipPro Data Models Unit Tests', () {
    test('User serialization and deserialization', () {
      final user = User(
        id: 'usr_test',
        username: 'test_user',
        displayName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Hello ZipPro!',
        followersCount: 100,
        followingCount: 50,
        isVerified: true,
      );

      final json = user.toJson();
      expect(json['username'], 'test_user');
      expect(json['isVerified'], true);

      final deserialized = User.fromJson(json);
      expect(deserialized.id, 'usr_test');
      expect(deserialized.displayName, 'Test User');
      expect(deserialized.followersCount, 100);
    });

    test('Message serialization and copyWith', () {
      final message = Message(
        id: 'msg_1',
        senderId: 'usr_1',
        receiverId: 'usr_2',
        content: 'Hello World',
        type: MessageType.text,
        timestamp: DateTime.parse('2026-03-01T12:00:00Z'),
      );

      final updated = message.copyWith(reaction: '🔥', isSeen: true);
      expect(updated.reaction, '🔥');
      expect(updated.isSeen, true);

      final json = updated.toJson();
      final deserialized = Message.fromJson(json);
      expect(deserialized.content, 'Hello World');
      expect(deserialized.reaction, '🔥');
    });

    test('Story expiration check', () {
      final freshStory = Story(
        id: 'st_1',
        userId: 'usr_1',
        username: 'User 1',
        userAvatar: 'https://example.com/a.jpg',
        mediaUrl: 'https://example.com/media.jpg',
        mediaType: MediaType.photo,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(freshStory.checkExpired, false);

      final oldStory = Story(
        id: 'st_2',
        userId: 'usr_1',
        username: 'User 1',
        userAvatar: 'https://example.com/a.jpg',
        mediaUrl: 'https://example.com/media.jpg',
        mediaType: MediaType.photo,
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
      );

      expect(oldStory.checkExpired, true);
    });
  });
}
