import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../screens/chats/chats_screen.dart';
import '../../screens/status/status_screen.dart';
import '../../screens/communities/communities_screen.dart';
import '../../screens/calls/calls_screen.dart';
import '../../screens/groups/create_group_screen.dart';
import '../../screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: AppConstants.accentColor,
      onPressed: () {
        if (_tabController.index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        } else if (_tabController.index == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera opened for status update')),
          );
        } else if (_tabController.index == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New community creation')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New call dialer opened')),
          );
        }
      },
      child: Icon(
        _tabController.index == 0
            ? Icons.message
            : _tabController.index == 1
                ? Icons.camera_alt
                : _tabController.index == 2
                    ? Icons.groups
                    : Icons.add_call,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera opened')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              } else if (val == 'new_group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'new_group', child: Text('New group')),
              const PopupMenuItem(value: 'new_community', child: Text('New community')),
              const PopupMenuItem(value: 'starred', child: Text('Starred messages')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.accentColor,
          labelColor: AppConstants.accentColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Updates'),
            Tab(text: 'Communities'),
            Tab(text: 'Calls'),
          ],
          onTap: (index) {
            setState(() {});
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ChatsScreen(),
          StatusScreen(),
          CommunitiesScreen(),
          CallsScreen(),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }
}
