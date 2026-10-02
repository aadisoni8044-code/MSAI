import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../models/media_model.dart';
import '../services/storage_service.dart';

class StoryProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Story> _stories = [];

  List<Story> get stories => _stories.where((s) => !s.checkExpired).toList();

  StoryProvider() {
    _initStories();
  }

  Future<void> _initStories() async {
    await _storage.init();
    final saved = _storage.getStories();

    if (saved.isNotEmpty) {
      _stories = saved;
    } else {
      _stories = [
        Story(
          id: 'story_my_1',
          userId: 'usr_me',
          username: 'alex_zippro',
          userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
          mediaType: MediaType.photo,
          caption: 'Morning vibes in the city 🌆',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          viewsCount: 42,
        ),
        Story(
          id: 'story_2',
          userId: 'friend_1',
          username: 'Sarah Connor',
          userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
          mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
          mediaType: MediaType.photo,
          caption: 'Beach sunset 🏖️',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          viewsCount: 128,
        ),
        Story(
          id: 'story_3',
          userId: 'friend_2',
          username: 'David Miller',
          userAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
          mediaUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
          mediaType: MediaType.photo,
          caption: 'Mountain hike adventure 🏔️',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          viewsCount: 95,
        ),
      ];
      await _storage.saveStories(_stories);
    }
    notifyListeners();
  }

  List<Story> getMyStories() {
    return stories.where((s) => s.userId == 'usr_me').toList();
  }

  List<Story> getFriendsStories() {
    return stories.where((s) => s.userId != 'usr_me').toList();
  }

  Future<void> addStory({
    required String mediaUrl,
    required MediaType mediaType,
    String? caption,
  }) async {
    final newStory = Story(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr_me',
      username: 'alex_zippro',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      createdAt: DateTime.now(),
      viewsCount: 0,
    );
    _stories.insert(0, newStory);
    notifyListeners();
    await _storage.saveStories(_stories);
  }

  Future<void> deleteStory(String storyId) async {
    _stories.removeWhere((s) => s.id == storyId);
    notifyListeners();
    await _storage.saveStories(_stories);
  }
}
