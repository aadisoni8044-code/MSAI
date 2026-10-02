import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/media_model.dart';
import '../services/storage_service.dart';

class DiscoverProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Post> _posts = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> categories = ['All', 'Trending', 'Travel', 'Tech', 'Music', 'Fitness', 'Art'];

  List<Post> get posts {
    return _posts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.authorName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get selectedCategory => _selectedCategory;

  DiscoverProvider() {
    _initPosts();
  }

  Future<void> _initPosts() async {
    await _storage.init();
    final saved = _storage.getPosts();

    if (saved.isNotEmpty) {
      _posts = saved;
    } else {
      _posts = [
        Post(
          id: 'post_1',
          authorName: 'Aria Chen',
          authorUsername: 'ariachen',
          authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
          title: 'Neon Lights Cyber Exploration 🌆',
          description: 'Testing ZipPro camera color grading in low light streets. What do you think?',
          mediaUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=800&q=80',
          mediaType: MediaType.photo,
          category: 'Tech',
          likesCount: 342,
          commentsCount: 28,
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        Post(
          id: 'post_2',
          authorName: 'Liam Walker',
          authorUsername: 'liam_w',
          authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
          title: 'Alpine Summit Trails 🏔️',
          description: 'High in the clouds with nothing but fresh air and blue skies.',
          mediaUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
          mediaType: MediaType.photo,
          category: 'Travel',
          likesCount: 890,
          commentsCount: 64,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Post(
          id: 'post_3',
          authorName: 'Maya Patel',
          authorUsername: 'maya_p',
          authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          title: 'Acoustic Sessions 🎸',
          description: 'Late night jam session captured with high-fidelity audio.',
          mediaUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80',
          mediaType: MediaType.photo,
          category: 'Music',
          likesCount: 512,
          commentsCount: 39,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      await _storage.savePosts(_posts);
    }
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final post = _posts[idx];
      _posts[idx] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      );
      notifyListeners();
      await _storage.savePosts(_posts);
    }
  }
}
