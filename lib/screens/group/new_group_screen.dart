import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../models/chat.dart';
import '../../services/mock_service.dart';
import '../../widgets/avatar.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final MockService _mockService = MockService();
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedUserIds = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _createGroup() {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 member')),
      );
      return;
    }

    final newGroup = _mockService.createGroupChat(
      _groupNameController.text.trim(),
      _selectedUserIds,
    );

    Navigator.pop(context, newGroup);
  }

  @override
  Widget build(BuildContext context) {
    final users = _mockService.users;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Group Name',
                prefixIcon: Icon(Icons.group_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Members', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = _selectedUserIds.contains(user.id);
                return CheckboxListTile(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  secondary: Avatar(imageUrl: user.avatarUrl, radius: 20),
                  title: Text(user.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(user.about, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedUserIds.add(user.id);
                      } else {
                        _selectedUserIds.remove(user.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
