import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../widgets/user_avatar.dart';

class GroupInfoScreen extends StatelessWidget {
  final String groupId;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => groupProvider.groups.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: UserAvatar(
                avatarUrl: group.avatarUrl,
                name: group.name,
                radius: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              group.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Group • ${group.members.length} participants',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Description'),
              subtitle: Text(group.description.isNotEmpty ? group.description : 'Add group description'),
              trailing: const Icon(Icons.edit, color: Colors.teal),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Mute notifications'),
              value: group.isMuted,
              onChanged: (val) => groupProvider.toggleMuteGroup(group.id),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${group.members.length} participants',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ),
            ...group.members.map((member) {
              final isAdmin = member.id == group.adminId;
              return ListTile(
                leading: UserAvatar(
                  avatarUrl: member.avatarUrl,
                  name: member.name,
                  radius: 20,
                ),
                title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(member.about, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isAdmin
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Group Admin', style: TextStyle(color: Colors.teal, fontSize: 10)),
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
