import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipgram/core/constants/app_colors.dart';
import 'package:zipgram/core/theme/app_theme.dart';
import 'package:zipgram/widgets/zipgram_logo.dart';
import 'package:zipgram/widgets/scanning_radar.dart';
import 'package:zipgram/models/chat_message.dart';
import 'package:zipgram/widgets/chat_bubble.dart';
import 'package:zipgram/services/bluetooth_service.dart';
import 'package:zipgram/services/storage_service.dart';
import 'package:zipgram/providers/bluetooth_provider.dart';
import 'package:zipgram/providers/chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UI Components Tests', () {
    testWidgets('ZipgramLogo renders icon and wordmark correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZipgramLogo(
              size: 40,
              style: ZipgramLogoStyle.iconAndWordmark,
            ),
          ),
        ),
      );

      expect(find.text('ZIP'), findsOneWidget);
      expect(find.text('gram'), findsOneWidget);
    });

    testWidgets('ScanningRadar renders with active scan', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScanningRadar(isScanning: true, size: 200),
          ),
        ),
      );

      expect(find.byType(ScanningRadar), findsOneWidget);
    });

    testWidgets('ChatBubble renders sent message', (WidgetTester tester) async {
      final msg = ChatMessage(
        id: '1',
        senderId: 'user_local_me',
        recipientId: 'peer_1',
        text: 'Hello via Bluetooth!',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ChatBubble(
              message: msg,
              isMe: true,
              onReply: (_) {},
              onDelete: (_) {},
              onReact: (_, __) {},
            ),
          ),
        ),
      );

      expect(find.text('Hello via Bluetooth!'), findsOneWidget);
    });
  });

  group('Bluetooth & Chat Provider Integration Tests', () {
    test('BluetoothService scan and connect flow', () async {
      final btService = BluetoothService();
      expect(btService.currentState, equals(BluetoothState.on));

      await btService.startScan();
      expect(btService.discoveredDevices.length, greaterThanOrEqualTo(3));

      final firstDevId = btService.discoveredDevices.first.id;
      final connected = await btService.connectToDevice(firstDevId);
      expect(connected, isTrue);
      expect(btService.connectedDevices.length, equals(1));

      await btService.disconnectDevice(firstDevId);
      expect(btService.connectedDevices.length, equals(0));
    });

    test('ChatProvider send message flow', () async {
      final storageService = StorageService();
      final btService = BluetoothService();

      final chatProvider = ChatProvider(
        bluetoothService: btService,
        storageService: storageService,
      );

      // Connect device first
      await btService.connectToDevice('zip_dev_alex');

      await chatProvider.sendMessage(
        recipientId: 'zip_dev_alex',
        text: 'Direct offline test message',
      );

      final msgs = chatProvider.getMessagesForPeer('zip_dev_alex');
      expect(msgs.any((m) => m.text == 'Direct offline test message'), isTrue);
    });
  });
}
