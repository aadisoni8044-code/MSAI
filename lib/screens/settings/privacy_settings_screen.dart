import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  String _lastSeen = 'Everyone';
  String _profilePhoto = 'Everyone';
  String _about = 'Everyone';
  String _status = 'My contacts';
  bool _readReceipts = true;

  void _showSelectionDialog(String title, String currentValue, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Everyone', 'My contacts', 'Nobody'].map((opt) {
            return RadioListTile<String>(
              title: Text(opt),
              value: opt,
              groupValue: currentValue,
              onChanged: (val) {
                if (val != null) {
                  onSelect(val);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Who can see my personal info',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Last seen and online'),
            subtitle: Text(_lastSeen),
            onTap: () => _showSelectionDialog('Last seen and online', _lastSeen, (v) => setState(() => _lastSeen = v)),
          ),
          ListTile(
            title: const Text('Profile photo'),
            subtitle: Text(_profilePhoto),
            onTap: () => _showSelectionDialog('Profile photo', _profilePhoto, (v) => setState(() => _profilePhoto = v)),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: Text(_about),
            onTap: () => _showSelectionDialog('About', _about, (v) => setState(() => _about = v)),
          ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(_status),
            onTap: () => _showSelectionDialog('Status', _status, (v) => setState(() => _status = v)),
          ),
          SwitchListTile(
            title: const Text('Read receipts'),
            subtitle: const Text("If turned off, you won't send or receive Read receipts."),
            value: _readReceipts,
            onChanged: (val) => setState(() => _readReceipts = val),
          ),
          const Divider(),
          const ListTile(
            title: Text('Blocked contacts'),
            subtitle: Text('None'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
