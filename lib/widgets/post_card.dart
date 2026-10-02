import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/media_preview.dart';
import '../core/theme/app_theme.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ProfileAvatar(
                  imageUrl: post.authorAvatar,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '@${post.authorUsername}',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(post.category, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppTheme.primaryCyan.withOpacity(0.15),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            width: double.infinity,
            child: MediaPreview(
              mediaPath: post.mediaUrl,
              isVideo: post.mediaType.name == 'video',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  post.description,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.isLiked ? AppTheme.accentPink : theme.colorScheme.onSurface,
                      ),
                      onPressed: onLike,
                    ),
                    Text('${post.likesCount}'),
                    const SizedBox(width: 16),
                    Icon(Icons.mode_comment_outlined, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 6),
                    Text('${post.commentsCount}'),
                    const Spacer(),
                    Icon(Icons.bookmark_border, color: theme.colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
