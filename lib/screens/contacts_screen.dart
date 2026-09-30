import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/bluetooth_provider.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final btProvider = context.watch<BluetoothProvider>();

    final contacts = chatProvider.contacts;
    final connectedDevices = btProvider.connectedDevices;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ZIPGRAM Contacts'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            tabs: const [
              Tab(text: 'ZIP Nearby'),
              Tab(text: 'Connected'),
              Tab(text: 'Saved Contacts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Section 1: ZIP Nearby
            _buildContactsList(
              context,
              contacts.where((c) => c.isNearby).toList(),
              btProvider,
              emptyText: 'No nearby ZIPGRAM devices detected.',
            ),

            // Section 2: Connected Devices
            _buildContactsList(
              context,
              contacts
                  .where((c) => connectedDevices.any((d) => d.id == c.id))
                  .toList(),
              btProvider,
              emptyText: 'No active Bluetooth device connections.',
            ),

            // Section 3: Saved Contacts
            _buildContactsList(
              context,
              contacts,
              btProvider,
              emptyText: 'No saved contacts available.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    List<dynamic> list,
    BluetoothProvider btProvider, {
    required String emptyText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final contact = list[index];
        final isConnected =
            btProvider.connectedDevices.any((d) => d.id == contact.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              contact.name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isConnected ? 'Connected over Bluetooth' : 'Nearby Offline',
            style: TextStyle(
              fontSize: 12,
              color: isConnected ? AppColors.connected : Colors.grey,
            ),
          ),
          trailing: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('CHAT'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
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
          ),
        );
      },
    );
  }
}
