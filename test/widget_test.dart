import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zipgram/main.dart';
import 'package:zipgram/services/bluetooth_service.dart';
import 'package:zipgram/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ZIPGRAM main app renders successfully', (WidgetTester tester) async {
    final storageService = StorageService();
    final bluetoothService = BluetoothService();

    await tester.pumpWidget(
      ZipgramApp(
        storageService: storageService,
        bluetoothService: bluetoothService,
      ),
    );

    expect(find.byType(ZipgramApp), findsOneWidget);
  });
}
