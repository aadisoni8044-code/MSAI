import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _conversationTones = true;
  bool _highPriority = true;
  bool _groupNotifications = true;
  bool _callVibrate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Conversation tones'),
            subtitle: const Text('Play sounds for incoming and outgoing messages.'),
            value: _conversationTones,
            onChanged: (val) => setState(() => _conversationTones = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Messages', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Notification tone'),
            subtitle: const Text('Default (Tone_1.mp3)'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Vibrate'),
            subtitle: const Text('Default'),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Use high priority notifications'),
            subtitle: const Text('Show previews of notifications at the top of the screen.'),
            value: _highPriority,
            onChanged: (val) => setState(() => _highPriority = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Groups', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Group notifications'),
            subtitle: const Text('Show notifications for group conversations.'),
            value: _groupNotifications,
            onChanged: (val) => setState(() => _groupNotifications = val),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Calls', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Ringtone'),
            subtitle: const Text('Default ringtone'),
            onTap: () {},
          ),
          SwitchListTile(
            title: const Text('Vibrate'),
            value: _callVibrate,
            onChanged: (val) => setState(() => _callVibrate = val),
          ),
        ],
      ),
    );
  }
}
