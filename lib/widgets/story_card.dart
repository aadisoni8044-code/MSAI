import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../widgets/profile_avatar.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final bool isAddStory;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    this.isAddStory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: isAddStory
              ? null
              : DecorationImage(
                  image: NetworkImage(story.mediaUrl),
                  fit: BoxFit.cover,
                ),
          color: isAddStory ? theme.colorScheme.surface : Colors.black26,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAddStory)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.black, size: 24),
                )
              else
                ProfileAvatar(
                  imageUrl: story.userAvatar,
                  radius: 16,
                  hasStory: true,
                ),
              Text(
                isAddStory ? 'Add Story' : story.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
