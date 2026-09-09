import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: AppConstants.accentColor),
          ),
          title: const Text('New Community', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Bring together neighborhood or project groups'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create community dialog opened')),
            );
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Your Communities',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code, color: Colors.blue),
          ),
          title: const Text('MSAI Developers', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Announcements · 3 Groups'),
          onTap: () {},
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hub, color: Colors.purple),
          ),
          title: const Text('Flutter Open Source Community', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Announcements · 5 Groups'),
          onTap: () {},
        ),
      ],
    );
  }
}
