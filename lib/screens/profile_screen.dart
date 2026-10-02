import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import '../providers/discover_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/post_card.dart';
import '../widgets/app_button.dart';
import 'settings_screen.dart';
import '../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProv = context.watch<AuthProvider>();
    final user = authProv.currentUser;
    final storyProv = context.watch<StoryProvider>();
    final discoverProv = context.watch<DiscoverProvider>();

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final myStories = storyProv.getMyStories();
    final myPosts = discoverProv.posts;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('@${user.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: user.avatarUrl,
                    radius: 42,
                    hasStory: myStories.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: AppTheme.primaryCyan, size: 20),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),

                  // Counts Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Stories', myStories.length.toString()),
                      _buildStatColumn('Followers', user.followersCount.toString()),
                      _buildStatColumn('Following', user.followingCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile Button
                  AppButton(
                    label: 'Edit Profile',
                    isPrimary: false,
                    width: double.infinity,
                    height: 42,
                    onPressed: () => _showEditProfileModal(context, authProv),
                  ),
                ],
              ),
            ),

            // Tab Bar
            const TabBar(
              indicatorColor: AppTheme.primaryCyan,
              labelColor: AppTheme.primaryCyan,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.auto_awesome_mosaic), text: 'My Stories'),
                Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
              ],
            ),

            // Tab View
            Expanded(
              child: TabBarView(
                children: [
                  // Stories Tab
                  myStories.isEmpty
                      ? const Center(child: Text('No active stories posted.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: myStories.length,
                          itemBuilder: (context, index) {
                            final story = myStories[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(story.mediaUrl, fit: BoxFit.cover),
                            );
                          },
                        ),

                  // Posts Tab
                  myPosts.isEmpty
                      ? const Center(child: Text('No posts shared yet.'))
                      : ListView.builder(
                          itemCount: myPosts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: myPosts[index],
                              onLike: () => discoverProv.toggleLike(myPosts[index].id),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  void _showEditProfileModal(BuildContext context, AuthProvider authProv) {
    final user = authProv.currentUser!;
    final nameController = TextEditingController(text: user.displayName);
    final bioController = TextEditingController(text: user.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit ZipPro Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save Changes',
                width: double.infinity,
                onPressed: () {
                  authProv.updateProfile(
                    displayName: nameController.text,
                    bio: bioController.text,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated! ✨')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
