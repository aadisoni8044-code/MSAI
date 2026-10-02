import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../models/story_model.dart';
import '../models/media_model.dart';
import '../widgets/story_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/media_preview.dart';
import '../core/theme/app_theme.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProv = context.watch<StoryProvider>();
    final myStories = storyProv.getMyStories();
    final friendsStories = storyProv.getFriendsStories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZipPro Stories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Story',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  StoryCard(
                    story: Story(
                      id: 'add',
                      userId: 'usr_me',
                      username: 'Add Story',
                      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                      mediaUrl: '',
                      mediaType: MediaType.photo,
                      createdAt: DateTime.now(),
                    ),
                    isAddStory: true,
                    onTap: () => _showAddStoryModal(context),
                  ),
                  ...myStories.map((s) => StoryCard(
                        story: s,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoryViewerScreen(
                                stories: myStories,
                                initialIndex: myStories.indexOf(s),
                              ),
                            ),
                          );
                        },
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Friends\' Stories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (friendsStories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No active stories from friends.'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: friendsStories.length,
                itemBuilder: (context, index) {
                  final story = friendsStories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryViewerScreen(
                            stories: friendsStories,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(story.mediaUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileAvatar(
                              imageUrl: story.userAvatar,
                              radius: 18,
                              hasStory: true,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${story.createdAt.hour}:${story.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAddStoryModal(BuildContext context) {
    final captionController = TextEditingController();

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
              const Text(
                'Create Quick Story',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Share a story caption...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  context.read<StoryProvider>().addStory(
                        mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
                        mediaType: MediaType.photo,
                        caption: captionController.text,
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Story posted to ZipPro! ⚡️')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Post Story'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _timer?.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _timer?.cancel(),
        onLongPressEnd: (_) => _startTimer(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final st = widget.stories[index];
                return MediaPreview(
                  mediaPath: st.mediaUrl,
                  isVideo: st.mediaType == MediaType.video,
                  fit: BoxFit.contain,
                );
              },
            ),

            // Top Header & Progress Indicator
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24,
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ProfileAvatar(imageUrl: story.userAvatar, radius: 18),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${story.viewsCount} views • ZipPro Story',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (story.userId == 'usr_me')
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              context.read<StoryProvider>().deleteStory(story.id);
                              Navigator.pop(context);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Story Caption at Bottom
            if (story.caption != null && story.caption!.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    story.caption!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
