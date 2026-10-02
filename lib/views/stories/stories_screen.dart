import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/glass_theme.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/story_provider.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassTheme.glassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      borderRadius: 20,
                      child: const Text(
                        'STORIES',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    GlassTheme.glassContainer(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 20,
                      child: const Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Stories Carousel Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  'RECENT SNAPS & STORIES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Top Horizontal Stories Bar
              SizedBox(
                height: 110,
                child: Consumer<StoryProvider>(
                  builder: (context, storyProv, child) {
                    final stories = storyProv.stories;

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        final isAdd = index == 0;

                        return GestureDetector(
                          onTap: () {
                            if (isAdd) {
                              context.read<NavigationProvider>().goToCamera();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isAdd ? AppColors.accent : AppColors.neonPink,
                                          width: 2.5,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(story.userAvatar),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    if (isAdd)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: AppColors.primary,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    story.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Feed Stream Section Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Text(
                  'COMMUNITY DISCOVERY FEED',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Feed Cards List
              Consumer<StoryProvider>(
                builder: (context, storyProv, child) {
                  final feedPosts = storyProv.feedPosts;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: feedPosts.length,
                    itemBuilder: (context, index) {
                      final post = feedPosts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: GlassTheme.glassContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(post.userAvatar),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.userName,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${post.timeAgo} • Filter: ${post.filterName}',
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: AppColors.textMuted,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Post Image Container
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(post.mediaUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: GlassTheme.glassContainer(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            borderRadius: 12,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  FontAwesomeIcons.wandMagicSparkles,
                                                  color: AppColors.accent,
                                                  size: 11,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  post.filterName,
                                                  style: const TextStyle(
                                                    color: AppColors.accent,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Caption & Reactions Row
                              Text(
                                post.caption,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          post.isLiked
                                              ? FontAwesomeIcons.solidHeart
                                              : FontAwesomeIcons.heart,
                                          color: post.isLiked
                                              ? AppColors.neonPink
                                              : AppColors.textSecondary,
                                          size: 18,
                                        ),
                                        onPressed: () => storyProv.toggleLike(post.id),
                                      ),
                                      Text(
                                        '${post.likesCount}',
                                        style: TextStyle(
                                          color: post.isLiked
                                              ? AppColors.neonPink
                                              : AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.comment,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.share,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
