import 'package:flutter/material.dart';
import '../../models/group.dart';
import '../../widgets/user_avatar.dart';

class GroupDetailScreen extends StatelessWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              UserAvatar(name: group.name, url: group.avatarUrl, radius: 48),
              const SizedBox(height: 16),
              Text(
                group.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Group · ${group.memberIds.length} members',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              if (group.description.isNotEmpty) ...[
                ListTile(
                  title: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(group.description),
                ),
                const Divider(),
              ],
              ListTile(
                title: Text('${group.memberIds.length} Participants'),
                trailing: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add members sheet opened')),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: group.memberIds.length,
                itemBuilder: (ctx, index) {
                  final memberId = group.memberIds[index];
                  final isAdmin = group.adminIds.contains(memberId);
                  return ListTile(
                    leading: UserAvatar(name: 'Member $index', radius: 20),
                    title: Text('Member ($memberId)'),
                    trailing: isAdmin
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Group Admin',
                              style: TextStyle(color: Colors.green, fontSize: 10),
                            ),
                          )
                        : null,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Exit Group', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
