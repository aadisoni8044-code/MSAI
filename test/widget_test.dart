import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zipgram/main.dart';
import 'package:zipgram/services/chat_service.dart';
import 'package:zipgram/services/settings_service.dart';

void main() {
  testWidgets('ZIPGRAM application loads splash screen and main dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ZipgramApp());

    expect(find.text('ZIPGRAM'), findsOneWidget);
    expect(find.text('Next-Gen Messaging'), findsOneWidget);

    // Fast-forward splash screen timer
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should now display the main chats screen
    expect(find.text('Chats'), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
  });

  testWidgets('Theme switching toggles dark mode state', (WidgetTester tester) async {
    final settingsService = SettingsService();
    expect(settingsService.isDarkMode, isTrue);

    settingsService.toggleTheme();
    expect(settingsService.isDarkMode, isFalse);
  });

  test('Chat service sends and receives demo messages', () {
    final chatService = ChatService();
    final initialChats = chatService.chats;
    expect(initialChats.isNotEmpty, isTrue);

    final chat = initialChats.first;
    chatService.sendMessage(chatId: chat.id, text: 'Test message for ZIPGRAM unit test');

    final messages = chatService.getMessagesForChat(chat.id);
    expect(messages.any((m) => m.content == 'Test message for ZIPGRAM unit test'), isTrue);
  });
}
