import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/bluetooth_provider.dart';
import '../services/bluetooth_service.dart';
import '../widgets/scanning_radar.dart';
import '../widgets/nearby_device_card.dart';
import 'chat_screen.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final btProvider = context.watch<BluetoothProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby ZIPGRAM Devices'),
        actions: [
          Switch.adaptive(
            value: btProvider.state != BluetoothState.off,
            onChanged: (val) {
              btProvider.toggleBluetooth(val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Bluetooth Status Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Row(
              children: [
                Icon(
                  btProvider.state == BluetoothState.off
                      ? Icons.bluetooth_disabled
                      : btProvider.state == BluetoothState.scanning
                          ? Icons.bluetooth_searching
                          : btProvider.state == BluetoothState.connected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                  color: btProvider.state == BluetoothState.off
                      ? Colors.red
                      : AppColors.primaryLight,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text(
                        _getBluetoothStatusTitle(btProvider.state),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _getBluetoothStatusSubtitle(btProvider.state),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (btProvider.state == BluetoothState.permissionRequired)
                  ElevatedButton(
                    onPressed: () => btProvider.requestPermissions(),
                    child: const Text('GRANT'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Error Banner if present
          if (btProvider.errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      btProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    onPressed: () => btProvider.clearError(),
                  ),
                ],
              ),
            ),

          // Radar Scan Visualizer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                ScanningRadar(isScanning: btProvider.isScanning),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!btProvider.isScanning)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text('SCAN NEARBY'),
                        onPressed: btProvider.state == BluetoothState.off
                            ? null
                            : () => btProvider.startScan(),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('STOP SCAN'),
                        onPressed: () => btProvider.stopScan(),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          // Discovered Devices Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DISCOVERED DEVICES (${btProvider.discoveredDevices.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
                if (btProvider.isScanning)
                  const Text(
                    'Searching...',
                    style: TextStyle(fontSize: 12, color: AppColors.primaryLight),
                  ),
              ],
            ),
          ),

          // Discovered Devices List View
          Expanded(
            child: btProvider.discoveredDevices.isEmpty
                ? Center(
                    child: Text(
                      btProvider.isScanning
                          ? 'Scanning for compatible ZIPGRAM devices...'
                          : 'No nearby devices discovered. Tap SCAN to search.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: btProvider.discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = btProvider.discoveredDevices[index];
                      return NearbyDeviceCard(
                        device: device,
                        onConnect: () => _confirmConnect(context, btProvider, device.id, device.name),
                        onDisconnect: () => btProvider.disconnectDevice(device.id),
                        onBlock: () => btProvider.blockDevice(device.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmConnect(BuildContext context, BluetoothProvider btProvider,
      String deviceId, String name) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Connect to $name?'),
          content: const Text(
            'Establishing a Bluetooth connection allows offline messaging without internet. Proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await btProvider.connectDevice(deviceId);
                if (success && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        peerId: deviceId,
                        peerName: name,
                      ),
                    ),
                  );
                }
              },
              child: const Text('CONNECT'),
            ),
          ],
        );
      },
    );
  }

  String _getBluetoothStatusTitle(BluetoothState state) {
    switch (state) {
      case BluetoothState.off:
        return 'Bluetooth is Turned OFF';
      case BluetoothState.permissionRequired:
        return 'Bluetooth Permissions Required';
      case BluetoothState.scanning:
        return 'Scanning Nearby Devices...';
      case BluetoothState.connected:
        return 'Connected & Ready';
      case BluetoothState.on:
        return 'Bluetooth Active & Discoverable';
    }
  }

  String _getBluetoothStatusSubtitle(BluetoothState state) {
    switch (state) {
      case BluetoothState.off:
        return 'Enable Bluetooth to discover and message nearby users.';
      case BluetoothState.permissionRequired:
        return 'ZIPGRAM requires Bluetooth permissions to scan nearby peers.';
      case BluetoothState.scanning:
        return 'Locating nearby compatible ZIPGRAM nodes.';
      case BluetoothState.connected:
        return 'Offline Bluetooth link established.';
      case BluetoothState.on:
        return 'Tap SCAN NEARBY to find devices.';
    }
  }
}
