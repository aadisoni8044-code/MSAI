import 'dart:async';

abstract class NetworkService {
  bool get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class MockNetworkService implements NetworkService {
  bool _isConnected = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  void setConnected(bool connected) {
    _isConnected = connected;
    _connectivityController.add(_isConnected);
  }

  void dispose() {
    _connectivityController.close();
  }
}
