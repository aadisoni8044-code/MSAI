import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipgram/models/chat_message.dart';
import 'package:zipgram/models/nearby_device.dart';
import 'package:zipgram/models/contact.dart';
import 'package:zipgram/models/user_profile.dart';
import 'package:zipgram/models/app_settings.dart';
import 'package:zipgram/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model JSON Tests', () {
    test('ChatMessage JSON serialization and deserialization', () {
      final message = ChatMessage(
        id: 'msg_1',
        senderId: 'user_1',
        recipientId: 'user_2',
        text: 'Hello via Bluetooth!',
        timestamp: DateTime(2026, 1, 1, 12, 0),
        status: MessageStatus.sent,
      );

      final jsonMap = message.toJson();
      final restored = ChatMessage.fromJson(jsonMap);

      expect(restored.id, equals(message.id));
      expect(restored.text, equals(message.text));
      expect(restored.status, equals(message.status));
    });

    test('NearbyDevice JSON serialization', () {
      final device = NearbyDevice(
        id: 'dev_1',
        name: 'Alex Phone',
        deviceType: 'Phone',
        connectionState: DeviceConnectionState.connected,
      );

      final restored = NearbyDevice.fromJson(device.toJson());
      expect(restored.name, equals('Alex Phone'));
      expect(restored.connectionState, equals(DeviceConnectionState.connected));
    });
  });

  group('StorageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Save and Load User Profile', () async {
      final storage = StorageService();
      final profile = UserProfile(
        id: 'me',
        username: 'zip_master',
        displayName: 'Zip Master',
      );

      await storage.saveUserProfile(profile);
      final loaded = await storage.loadUserProfile();

      expect(loaded.username, equals('zip_master'));
      expect(loaded.displayName, equals('Zip Master'));
    });

    test('Save and Load Messages', () async {
      final storage = StorageService();
      final messages = [
        ChatMessage(
          id: 'm1',
          senderId: 'me',
          recipientId: 'peer1',
          text: 'Hi peer',
          timestamp: DateTime.now(),
        ),
      ];

      await storage.saveMessagesForChat('peer1', messages);
      final loaded = await storage.loadMessagesForChat('peer1');

      expect(loaded.length, equals(1));
      expect(loaded.first.text, equals('Hi peer'));
    });
  });
}
