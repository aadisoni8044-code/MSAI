import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../widgets/zipgram_logo.dart';
import '../screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final btProvider = context.watch<BluetoothProvider>();

    final contacts = chatProvider.contacts.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats or nearby...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const ZipgramLogo(size: 28),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          // Bluetooth Status Badge Indicator
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Go to Nearby tab
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: btProvider.state == BluetoothState.connected
                      ? AppColors.connected.withValues(alpha: 0.15)
                      : btProvider.state == BluetoothState.scanning
                          ? AppColors.scanning.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: btProvider.state == BluetoothState.connected
                        ? AppColors.connected
                        : btProvider.state == BluetoothState.scanning
                            ? AppColors.scanning
                            : AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      btProvider.state == BluetoothState.connected
                          ? Icons.bluetooth_connected
                          : btProvider.state == BluetoothState.scanning
                              ? Icons.bluetooth_searching
                              : Icons.bluetooth,
                      size: 16,
                      color: btProvider.state == BluetoothState.connected
                          ? AppColors.connected
                          : btProvider.state == BluetoothState.scanning
                              ? AppColors.scanning
                              : AppColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      btProvider.state == BluetoothState.connected
                          ? 'CONNECTED'
                          : btProvider.state == BluetoothState.scanning
                              ? 'SCANNING'
                              : 'BT ON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: btProvider.state == BluetoothState.connected
                            ? AppColors.connected
                            : btProvider.state == BluetoothState.scanning
                                ? AppColors.scanning
                                : AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: contacts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.connect_without_contact,
                      size: 64,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Conversations Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan nearby Bluetooth devices to connect and chat directly without internet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bluetooth_searching),
                      label: const Text('Discover Nearby Devices'),
                      onPressed: () {
                        if (widget.onNavigateToTab != null) {
                          widget.onNavigateToTab!(1); // Navigate to Nearby screen
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const Divider(indent: 72),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isConnected = btProvider.connectedDevices
                    .any((d) => d.id == contact.id);

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          contact.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected
                                ? AppColors.connected
                                : AppColors.darkBorder,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact.lastMessageTime != null)
                        Text(
                          DateFormat('HH:mm').format(contact.lastMessageTime!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: contact.unreadCount > 0
                                  ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                              fontWeight: contact.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (contact.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${contact.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          peerId: contact.id,
                          peerName: contact.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
