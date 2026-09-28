import 'package:flutter_test/flutter_test.dart';
import 'package:zipgram/models/user.dart';
import 'package:zipgram/models/message.dart';
import 'package:zipgram/models/chat.dart';
import 'package:zipgram/services/mock_service.dart';

void main() {
  group('ZipGram Models & MockService Tests', () {
    test('User model properties', () {
      const user = User(
        id: 'test_1',
        name: 'Test User',
        username: 'testuser',
        avatarUrl: 'https://example.com/avatar.jpg',
        about: 'Testing ZipGram',
        isOnline: true,
        phoneNumber: '+10000000',
      );

      expect(user.id, 'test_1');
      expect(user.name, 'Test User');
      expect(user.isOnline, isTrue);
    });

    test('MockService initial data load and message sending', () {
      final mockService = MockService();

      expect(mockService.chats.isNotEmpty, isTrue);
      expect(mockService.users.isNotEmpty, isTrue);

      final initialCount = mockService.getMessages('c1').length;
      mockService.sendMessage('c1', 'Test message from unit test');

      final updatedMessages = mockService.getMessages('c1');
      expect(updatedMessages.length, equals(initialCount + 1));
      expect(updatedMessages.last.content, equals('Test message from unit test'));
    });

    test('MockService group chat creation', () {
      final mockService = MockService();
      final group = mockService.createGroupChat('Test Flutter Group', ['u1', 'u2']);

      expect(group.isGroup, isTrue);
      expect(group.name, equals('Test Flutter Group'));
      expect(mockService.chats.contains(group), isTrue);
    });
  });
}
