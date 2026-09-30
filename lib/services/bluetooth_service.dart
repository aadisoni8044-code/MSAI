import 'dart:async';
import 'dart:math';
import '../models/nearby_device.dart';
import '../models/chat_message.dart';

enum BluetoothPermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

enum BluetoothState {
  off,
  on,
  permissionRequired,
  scanning,
  connected,
}

class BluetoothService {
  BluetoothState _state = BluetoothState.on;
  BluetoothPermissionStatus _permissionStatus = BluetoothPermissionStatus.granted;
  bool _isScanning = false;

  final List<NearbyDevice> _discoveredDevices = [];
  final List<NearbyDevice> _connectedDevices = [];
  final List<String> _blockedDeviceIds = [];

  final StreamController<BluetoothState> _stateController =
      StreamController<BluetoothState>.broadcast();
  final StreamController<List<NearbyDevice>> _devicesController =
      StreamController<List<NearbyDevice>>.broadcast();
  final StreamController<ChatMessage> _incomingMessageController =
      StreamController<ChatMessage>.broadcast();

  Stream<BluetoothState> get stateStream => _stateController.stream;
  Stream<List<NearbyDevice>> get devicesStream => _devicesController.stream;
  Stream<ChatMessage> get incomingMessageStream => _incomingMessageController.stream;

  BluetoothState get currentState => _state;
  BluetoothPermissionStatus get permissionStatus => _permissionStatus;
  bool get isScanning => _isScanning;
  List<NearbyDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  List<NearbyDevice> get connectedDevices => List.unmodifiable(_connectedDevices);

  BluetoothService() {
    _initDefaultNearbyDevices();
  }

  void _initDefaultNearbyDevices() {
    // Initial mock nearby ZIPGRAM devices for peer discovery experience
    _discoveredDevices.addAll([
      NearbyDevice(
        id: 'zip_dev_alex',
        name: 'Alex (ZIP Mobile)',
        deviceType: 'Phone',
        rssi: -52,
        connectionState: DeviceConnectionState.found,
      ),
      NearbyDevice(
        id: 'zip_dev_sara',
        name: 'Sara (ZIP Pad)',
        deviceType: 'Tablet',
        rssi: -68,
        connectionState: DeviceConnectionState.found,
      ),
      NearbyDevice(
        id: 'zip_dev_laptop',
        name: 'Workstation Desktop',
        deviceType: 'Desktop',
        rssi: -75,
        connectionState: DeviceConnectionState.found,
      ),
    ]);
  }

  Future<bool> checkAndRequestPermissions() async {
    // Platform agnostic permission check logic
    if (_permissionStatus == BluetoothPermissionStatus.permanentlyDenied) {
      return false;
    }
    _permissionStatus = BluetoothPermissionStatus.granted;
    if (_state == BluetoothState.permissionRequired) {
      _state = BluetoothState.on;
      _stateController.add(_state);
    }
    return true;
  }

  void toggleBluetooth(bool enabled) {
    if (enabled) {
      _state = BluetoothState.on;
    } else {
      _state = BluetoothState.off;
      _isScanning = false;
      // Disconnect active devices
      for (var dev in _connectedDevices) {
        _updateDeviceState(dev.id, DeviceConnectionState.disconnected);
      }
      _connectedDevices.clear();
    }
    _stateController.add(_state);
  }

  Future<void> startScan() async {
    if (_state == BluetoothState.off) {
      throw Exception("Bluetooth is powered OFF. Enable Bluetooth to scan.");
    }
    if (_permissionStatus != BluetoothPermissionStatus.granted) {
      _state = BluetoothState.permissionRequired;
      _stateController.add(_state);
      throw Exception("Bluetooth permissions are required for nearby discovery.");
    }

    _isScanning = true;
    _state = BluetoothState.scanning;
    _stateController.add(_state);

    // Simulate active scan discovery over 3 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!_isScanning) return;

    // Dynamically simulate discovering a new compatible nearby ZIPGRAM node
    final random = Random();
    final nodeNames = [
      'David (ZIP Phone)',
      'Elena (ZIP Book)',
      'Marcus (ZIP Ultra)',
      'Sophia (ZIP Node)'
    ];
    final selectedName = nodeNames[random.nextInt(nodeNames.length)];
    final newId = 'zip_dev_${DateTime.now().millisecondsSinceEpoch % 10000}';

    if (!_discoveredDevices.any((d) => d.name == selectedName)) {
      _discoveredDevices.add(
        NearbyDevice(
          id: newId,
          name: selectedName,
          deviceType: selectedName.contains('Pad') || selectedName.contains('Book')
              ? 'Tablet'
              : selectedName.contains('Ultra')
                  ? 'Desktop'
                  : 'Phone',
          rssi: -(40 + random.nextInt(45)),
          connectionState: DeviceConnectionState.found,
        ),
      );
    }

    _isScanning = false;
    _state = _connectedDevices.isNotEmpty ? BluetoothState.connected : BluetoothState.on;
    _stateController.add(_state);
    _devicesController.add(_discoveredDevices);
  }

  void stopScan() {
    _isScanning = false;
    _state = _connectedDevices.isNotEmpty ? BluetoothState.connected : BluetoothState.on;
    _stateController.add(_state);
  }

  Future<bool> connectToDevice(String deviceId) async {
    final index = _discoveredDevices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    if (_blockedDeviceIds.contains(deviceId)) {
      throw Exception("Cannot connect: This device is blocked.");
    }

    _updateDeviceState(deviceId, DeviceConnectionState.connecting);

    // Connection handshake over Bluetooth simulation
    await Future.delayed(const Duration(milliseconds: 1500));

    final device = _discoveredDevices[index];
    final connectedDevice = device.copyWith(
      connectionState: DeviceConnectionState.connected,
    );

    _discoveredDevices[index] = connectedDevice;
    if (!_connectedDevices.any((d) => d.id == deviceId)) {
      _connectedDevices.add(connectedDevice);
    }

    _state = BluetoothState.connected;
    _stateController.add(_state);
    _devicesController.add(_discoveredDevices);

    return true;
  }

  Future<void> disconnectDevice(String deviceId) async {
    _connectedDevices.removeWhere((d) => d.id == deviceId);
    _updateDeviceState(deviceId, DeviceConnectionState.disconnected);

    if (_connectedDevices.isEmpty) {
      _state = BluetoothState.on;
      _stateController.add(_state);
    }
  }

  void blockDevice(String deviceId) {
    if (!_blockedDeviceIds.contains(deviceId)) {
      _blockedDeviceIds.add(deviceId);
    }
    disconnectDevice(deviceId);
    _discoveredDevices.removeWhere((d) => d.id == deviceId);
    _devicesController.add(_discoveredDevices);
  }

  void unblockDevice(String deviceId) {
    _blockedDeviceIds.remove(deviceId);
  }

  void _updateDeviceState(String deviceId, DeviceConnectionState newState) {
    final index = _discoveredDevices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _discoveredDevices[index] = _discoveredDevices[index].copyWith(
        connectionState: newState,
      );
      _devicesController.add(_discoveredDevices);
    }
  }

  Future<bool> sendMessageOverBluetooth(ChatMessage message) async {
    if (_state == BluetoothState.off) {
      return false;
    }

    final isConnected = _connectedDevices.any((d) => d.id == message.recipientId);
    if (!isConnected) {
      return false;
    }

    // Simulate quick Bluetooth protocol transmission delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Simulate automatic peer response for demonstration
    _triggerAutoPeerResponse(message.recipientId, message.text);

    return true;
  }

  void _triggerAutoPeerResponse(String recipientId, String sentText) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!_connectedDevices.any((d) => d.id == recipientId)) return;

      final responses = [
        "Received loud and clear via Bluetooth!",
        "ZIPGRAM offline direct connection working great!",
        "Got your message: '$sentText'",
        "No internet needed here. Super fast!",
      ];

      final replyText = responses[Random().nextInt(responses.length)];

      final incomingMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: recipientId,
        recipientId: 'user_local_me',
        text: replyText,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );

      _incomingMessageController.add(incomingMessage);
    });
  }

  void dispose() {
    _stateController.close();
    _devicesController.close();
    _incomingMessageController.close();
  }
}
