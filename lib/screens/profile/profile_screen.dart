import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _aboutController = TextEditingController(text: user?.about ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      final updated = currentUser.copyWith(
        name: _nameController.text.trim(),
        about: _aboutController.text.trim(),
      );
      final success = await authProvider.updateProfile(updated);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      name: user?.name ?? 'User',
                      url: user?.avatarUrl,
                      radius: 54,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppConstants.accentColor,
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.person),
                title: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: InputBorder.none,
                  ),
                ),
                subtitle: const Text('This is not your username or pin. This name will be visible to your contacts.'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: TextField(
                  controller: _aboutController,
                  decoration: const InputDecoration(
                    labelText: 'About',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(user?.phone.isNotEmpty == true ? user!.phone : 'Not provided'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user?.email.isNotEmpty == true ? user!.email : 'Not provided'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
