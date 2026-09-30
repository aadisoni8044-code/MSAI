import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../providers/bluetooth_provider.dart';

class ProfileScreen extends StatefulWidget {
  final StorageService storageService;

  const ProfileScreen({super.key, required this.storageService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _deviceNameController;

  UserProfile? _profile;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _deviceNameController = TextEditingController();
    _loadProfile();
  }

  void _loadProfile() async {
    final p = await widget.storageService.loadUserProfile();
    setState(() {
      _profile = p;
      _displayNameController.text = p.displayName;
      _usernameController.text = p.username;
      _bioController.text = p.bio;
      _deviceNameController.text = p.deviceName;
    });
  }

  void _saveProfile() async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      displayName: _displayNameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      deviceName: _deviceNameController.text.trim(),
    );

    await widget.storageService.saveUserProfile(updated);
    setState(() {
      _profile = updated;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final btProvider = context.watch<BluetoothProvider>();

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Avatar Display
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _profile!.displayName.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.extrabold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.connected,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bluetooth,
                          color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Identity & Status
            Text(
              _profile!.displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@${_profile!.username}',
              style: const TextStyle(color: AppColors.primaryLight, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Bluetooth Identity Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth_searching,
                        color: AppColors.primaryLight, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          const Text(
                            'Bluetooth Device Name',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.darkTextMuted),
                          ),
                          Text(
                            _profile!.deviceName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.connected.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DISCOVERABLE',
                        style: TextStyle(
                          color: AppColors.connected,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Form Fields
            _buildField(
              label: 'Display Name',
              controller: _displayNameController,
              enabled: _isEditing,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: 'Username',
              controller: _usernameController,
              enabled: _isEditing,
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: 'Device Name (Visible to nearby peers)',
              controller: _deviceNameController,
              enabled: _isEditing,
              icon: Icons.devices_other,
            ),
            const SizedBox(height: 12),
            _buildField(
              label: 'Bio / Status',
              controller: _bioController,
              enabled: _isEditing,
              icon: Icons.info_outline,
            ),

            if (_isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('SAVE PROFILE CHANGES'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }
}
