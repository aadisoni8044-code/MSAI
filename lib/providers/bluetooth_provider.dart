import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';
import '../models/nearby_device.dart';

class BluetoothProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService;
  final StorageService _storageService;

  late StreamSubscription _stateSub;
  late StreamSubscription _devicesSub;

  BluetoothState _state = BluetoothState.on;
  bool _isScanning = false;
  List<NearbyDevice> _discoveredDevices = [];
  List<NearbyDevice> _connectedDevices = [];
  List<String> _blockedDeviceIds = [];
  String? _errorMessage;

  BluetoothState get state => _state;
  bool get isScanning => _isScanning;
  List<NearbyDevice> get discoveredDevices => _discoveredDevices;
  List<NearbyDevice> get connectedDevices => _connectedDevices;
  List<String> get blockedDeviceIds => _blockedDeviceIds;
  String? get errorMessage => _errorMessage;

  BluetoothProvider({
    required BluetoothService bluetoothService,
    required StorageService storageService,
  })  : _bluetoothService = bluetoothService,
        _storageService = storageService {
    _init();
  }

  void _init() async {
    _state = _bluetoothService.currentState;
    _discoveredDevices = List.from(_bluetoothService.discoveredDevices);
    _connectedDevices = List.from(_bluetoothService.connectedDevices);

    _blockedDeviceIds = await _storageService.loadBlockedDeviceIds();

    _stateSub = _bluetoothService.stateStream.listen((newState) {
      _state = newState;
      _isScanning = _bluetoothService.isScanning;
      notifyListeners();
    });

    _devicesSub = _bluetoothService.devicesStream.listen((devices) {
      _discoveredDevices = List.from(devices);
      _connectedDevices = List.from(_bluetoothService.connectedDevices);
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleBluetooth(bool enabled) async {
    _bluetoothService.toggleBluetooth(enabled);
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    try {
      final success = await _bluetoothService.checkAndRequestPermissions();
      if (!success) {
        _errorMessage = "Bluetooth permissions denied. Please enable permissions in device settings.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> startScan() async {
    _errorMessage = null;
    try {
      await _bluetoothService.startScan();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    }
    notifyListeners();
  }

  void stopScan() {
    _bluetoothService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connectDevice(String deviceId) async {
    _errorMessage = null;
    try {
      final success = await _bluetoothService.connectToDevice(deviceId);
      _connectedDevices = List.from(_bluetoothService.connectedDevices);
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectDevice(String deviceId) async {
    await _bluetoothService.disconnectDevice(deviceId);
    _connectedDevices = List.from(_bluetoothService.connectedDevices);
    notifyListeners();
  }

  Future<void> blockDevice(String deviceId) async {
    _bluetoothService.blockDevice(deviceId);
    if (!_blockedDeviceIds.contains(deviceId)) {
      _blockedDeviceIds.add(deviceId);
      await _storageService.saveBlockedDeviceIds(_blockedDeviceIds);
    }
    _connectedDevices = List.from(_bluetoothService.connectedDevices);
    notifyListeners();
  }

  Future<void> unblockDevice(String deviceId) async {
    _bluetoothService.unblockDevice(deviceId);
    _blockedDeviceIds.remove(deviceId);
    await _storageService.saveBlockedDeviceIds(_blockedDeviceIds);
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _devicesSub.cancel();
    super.dispose();
  }
}
