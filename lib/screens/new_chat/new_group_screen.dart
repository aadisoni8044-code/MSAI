import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/mock_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/avatar_widget.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final List<User> _selectedUsers = [];
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group subject')),
      );
      return;
    }
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 member')),
      );
      return;
    }

    final newGroup = MockService().createGroupChat(name, _selectedUsers);
    Navigator.pushReplacementNamed(context, AppRoutes.groupChat, arguments: newGroup);
  }

  @override
  Widget build(BuildContext context) {
    final users = MockService().allUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primaryBlue),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.darkSurface,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBlue.withAlpha(51),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _groupNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type group subject...',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedUsers.isNotEmpty) ...[
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.darkBackground,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = _selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Stack(
                      children: [
                        AvatarWidget(
                          imageUrl: user.avatarUrl,
                          name: user.name,
                          radius: 22,
                          showOnlineIndicator: false,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUsers.remove(user);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = _selectedUsers.contains(user);
                return CheckboxListTile(
                  activeColor: AppColors.primaryBlue,
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                  secondary: AvatarWidget(
                    imageUrl: user.avatarUrl,
                    name: user.name,
                    radius: 20,
                    showOnlineIndicator: false,
                  ),
                  title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.statusMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.arrow_forward_rounded),
      ),
    );
  }
}
