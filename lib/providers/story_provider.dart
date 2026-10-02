import 'package:flutter/foundation.dart';

class StoryItem {
  final String id;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String filterName;
  final String timeAgo;
  final bool isSeen;

  StoryItem({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.filterName,
    required this.timeAgo,
    this.isSeen = false,
  });
}

class StoryFeedPost {
  final String id;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final String filterName;
  final String caption;
  final String timeAgo;
  int likesCount;
  bool isLiked;

  StoryFeedPost({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    required this.filterName,
    required this.caption,
    required this.timeAgo,
    required this.likesCount,
    this.isLiked = false,
  });
}

class StoryProvider extends ChangeNotifier {
  final List<StoryItem> _stories = [
    StoryItem(
      id: 's1',
      userName: 'Your Story',
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
      filterName: 'Zippro Ultra',
      timeAgo: 'Add Snap',
    ),
    StoryItem(
      id: 's2',
      userName: 'CyberAura',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=800&q=80',
      filterName: 'Cyberpunk',
      timeAgo: '12m ago',
    ),
    StoryItem(
      id: 's3',
      userName: 'NeonRider',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=800&q=80',
      filterName: 'Neon Cyan',
      timeAgo: '1h ago',
    ),
    StoryItem(
      id: 's4',
      userName: 'VaporPulse',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
      filterName: 'Vaporwave',
      timeAgo: '3h ago',
    ),
    StoryItem(
      id: 's5',
      userName: 'GlitchMaster',
      userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80',
      filterName: 'Matrix Rain',
      timeAgo: '5h ago',
    ),
  ];

  final List<StoryFeedPost> _feedPosts = [
    StoryFeedPost(
      id: 'p1',
      userName: 'CyberAura_99',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=800&q=80',
      filterName: 'Cyberpunk',
      caption: 'Late night cyberpunk vibes in Tokyo ⚡ #Zippro #Cyberpunk',
      timeAgo: '12m ago',
      likesCount: 342,
    ),
    StoryFeedPost(
      id: 'p2',
      userName: 'NeonRider',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=800&q=80',
      filterName: 'Neon Cyan',
      caption: 'Testing the 50 live filter carousel. Realtime HUD visor lens is 🔥',
      timeAgo: '1h ago',
      likesCount: 819,
    ),
    StoryFeedPost(
      id: 'p3',
      userName: 'VaporPulse',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      mediaUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
      filterName: 'Vaporwave',
      caption: 'Synthwave aesthetics live camera feed! ✨',
      timeAgo: '3h ago',
      likesCount: 1204,
    ),
  ];

  List<StoryItem> get stories => _stories;
  List<StoryFeedPost> get feedPosts => _feedPosts;

  void toggleLike(String postId) {
    final idx = _feedPosts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _feedPosts[idx];
      if (post.isLiked) {
        post.isLiked = false;
        post.likesCount--;
      } else {
        post.isLiked = true;
        post.likesCount++;
      }
      notifyListeners();
    }
  }

  void addStoryPost({
    required String mediaUrl,
    required String filterName,
    required String caption,
  }) {
    final newPost = StoryFeedPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'You',
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      mediaUrl: mediaUrl,
      filterName: filterName,
      caption: caption,
      timeAgo: 'Just now',
      likesCount: 1,
      isLiked: true,
    );
    _feedPosts.insert(0, newPost);
    notifyListeners();
  }
}
