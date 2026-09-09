import 'package:flutter_test/flutter_test.dart';
import 'package:msai_chat/models/message.dart';
import 'package:msai_chat/providers/chat_provider.dart';
import 'package:msai_chat/providers/message_provider.dart';
import 'package:msai_chat/repositories/chat_repository.dart';
import 'package:msai_chat/repositories/message_repository.dart';
import 'package:msai_chat/services/chat_service.dart';
import 'package:msai_chat/services/message_service.dart';

void main() {
  group('Chat & Message Provider Tests', () {
    late ChatProvider chatProvider;
    late MessageProvider messageProvider;

    setUp(() {
      chatProvider = ChatProvider(
        chatRepository: ChatRepository(chatService: ApiChatService()),
      );
      messageProvider = MessageProvider(
        messageRepository: MessageRepository(messageService: ApiMessageService()),
      );
    });

    test('Create One to One Chat', () async {
      final chat = await chatProvider.startOneToOneChat('user_1', 'user_2');
      expect(chat.participantIds.contains('user_1'), true);
      expect(chat.participantIds.contains('user_2'), true);
    });

    test('Send text message and verify insertion', () async {
      final msg = Message(
        id: 'msg_1',
        chatId: 'chat_1',
        senderId: 'user_1',
        content: 'Testing chat messaging',
        timestamp: DateTime.now(),
      );

      await messageProvider.sendMessage(msg);
      final messages = messageProvider.getMessages('chat_1');
      expect(messages.length, 1);
      expect(messages.first.content, 'Testing chat messaging');
    });

    test('Delete message', () async {
      final msg = Message(
        id: 'msg_2',
        chatId: 'chat_2',
        senderId: 'user_1',
        content: 'To be deleted',
        timestamp: DateTime.now(),
      );

      await messageProvider.sendMessage(msg);
      expect(messageProvider.getMessages('chat_2').length, 1);

      await messageProvider.deleteMessage('chat_2', 'msg_2');
      expect(messageProvider.getMessages('chat_2').length, 0);
    });
  });
}
