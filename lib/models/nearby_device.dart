enum DeviceConnectionState {
  searching,
  found,
  connecting,
  connected,
  disconnected,
  connectionFailed,
}

class NearbyDevice {
  final String id;
  final String name;
  final String deviceType; // Phone, Tablet, Desktop
  final DeviceConnectionState connectionState;
  final int rssi; // Signal strength -100 to 0
  final bool isBlocked;
  final DateTime lastSeen;

  NearbyDevice({
    required this.id,
    required this.name,
    this.deviceType = 'Phone',
    this.connectionState = DeviceConnectionState.disconnected,
    this.rssi = -60,
    this.isBlocked = false,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceType': deviceType,
      'connectionState': connectionState.name,
      'rssi': rssi,
      'isBlocked': isBlocked,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory NearbyDevice.fromJson(Map<String, dynamic> json) {
    return NearbyDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceType: json['deviceType'] as String? ?? 'Phone',
      connectionState: DeviceConnectionState.values.firstWhere(
        (e) => e.name == json['connectionState'],
        orElse: () => DeviceConnectionState.disconnected,
      ),
      rssi: json['rssi'] as int? ?? -60,
      isBlocked: json['isBlocked'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : DateTime.now(),
    );
  }

  NearbyDevice copyWith({
    String? id,
    String? name,
    String? deviceType,
    DeviceConnectionState? connectionState,
    int? rssi,
    bool? isBlocked,
    DateTime? lastSeen,
  }) {
    return NearbyDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      connectionState: connectionState ?? this.connectionState,
      rssi: rssi ?? this.rssi,
      isBlocked: isBlocked ?? this.isBlocked,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
