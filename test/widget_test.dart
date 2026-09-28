import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipgram/core/theme/app_theme.dart';
import 'package:zipgram/models/chat.dart';
import 'package:zipgram/models/message.dart';
import 'package:zipgram/widgets/chat_tile.dart';
import 'package:zipgram/widgets/message_bubble.dart';

void main() {
  group('ZipGram UI Widget Tests', () {
    testWidgets('ChatTile renders correctly', (WidgetTester tester) async {
      final chat = Chat(
        id: 'tile_1',
        name: 'Amit Kumar',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        unreadCount: 3,
        lastMessage: Message(
          id: 'm1',
          chatId: 'tile_1',
          senderId: 'u1',
          senderName: 'Amit Kumar',
          content: 'Hello ZipGram!',
          timestamp: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ChatTile(
              chat: chat,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Amit Kumar'), findsOneWidget);
      expect(find.text('Hello ZipGram!'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('MessageBubble renders outgoing and incoming messages', (WidgetTester tester) async {
      final message = Message(
        id: 'msg_1',
        chatId: 'c1',
        senderId: 'user_me',
        senderName: 'Alex Mercer',
        content: 'This is an outgoing test message',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: true,
            ),
          ),
        ),
      );

      expect(find.text('This is an outgoing test message'), findsOneWidget);
    });
  });
}
