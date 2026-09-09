import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../routes/app_routes.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  UserAvatar(
                    avatarUrl: user?.avatarUrl ?? '',
                    name: user?.name ?? 'User',
                    radius: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(user?.name ?? 'Alex Johnson'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.teal),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
            ),
            const Divider(indent: 72),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: Text(user?.about ?? 'Available'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.teal),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.editProfile),
              ),
            ),
            const Divider(indent: 72),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(user?.phoneNumber ?? '+1 555-0199'),
            ),
          ],
        ),
      ),
    );
  }
}
