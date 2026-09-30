enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  final AppThemeMode themeMode;
  final bool bluetoothEnabled;
  final bool nearbyDiscoveryVisible;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoConnectSavedDevices;

  AppSettings({
    this.themeMode = AppThemeMode.system,
    this.bluetoothEnabled = true,
    this.nearbyDiscoveryVisible = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoConnectSavedDevices = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'bluetoothEnabled': bluetoothEnabled,
      'nearbyDiscoveryVisible': nearbyDiscoveryVisible,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'autoConnectSavedDevices': autoConnectSavedDevices,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      bluetoothEnabled: json['bluetoothEnabled'] as bool? ?? true,
      nearbyDiscoveryVisible: json['nearbyDiscoveryVisible'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      autoConnectSavedDevices: json['autoConnectSavedDevices'] as bool? ?? false,
    );
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? bluetoothEnabled,
    bool? nearbyDiscoveryVisible,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoConnectSavedDevices,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      bluetoothEnabled: bluetoothEnabled ?? this.bluetoothEnabled,
      nearbyDiscoveryVisible:
          nearbyDiscoveryVisible ?? this.nearbyDiscoveryVisible,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoConnectSavedDevices:
          autoConnectSavedDevices ?? this.autoConnectSavedDevices,
    );
  }
}
