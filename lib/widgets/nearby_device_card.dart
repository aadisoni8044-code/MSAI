import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/nearby_device.dart';

class NearbyDeviceCard extends StatelessWidget {
  final NearbyDevice device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onBlock;

  const NearbyDeviceCard({
    super.key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isConnected = device.connectionState == DeviceConnectionState.connected;
    final isConnecting = device.connectionState == DeviceConnectionState.connecting;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Device Type Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.connected.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getDeviceIcon(device.deviceType),
                color: isConnected ? AppColors.connected : AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Device Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${device.rssi} dBm • ${device.deviceType}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Connection Action Button
            if (isConnecting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else if (isConnected)
              OutlinedButton.icon(
                icon: const Icon(Icons.link_off, size: 16),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: onDisconnect,
              )
            else
              ElevatedButton(
                onPressed: onConnect,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('CONNECT'),
              ),

            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'block') onBlock();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'block',
                  child: Text('Block Device'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.tablet_android;
      case 'desktop':
      case 'laptop':
        return Icons.laptop;
      default:
        return Icons.phone_android;
    }
  }
}
