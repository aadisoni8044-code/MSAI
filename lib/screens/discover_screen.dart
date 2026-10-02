import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/discover_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/app_text_field.dart';
import '../core/theme/app_theme.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoverProv = context.watch<DiscoverProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZipPro Discover', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppTextField(
                hintText: 'Search creators, trends & posts...',
                prefixIcon: Icons.search,
                onChanged: discoverProv.setSearchQuery,
              ),
            ),

            // Categories Selector
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: discoverProv.categories.length,
                itemBuilder: (context, index) {
                  final category = discoverProv.categories[index];
                  final isSelected = discoverProv.selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryCyan,
                      onSelected: (_) => discoverProv.selectCategory(category),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Posts Feed
            if (discoverProv.posts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No posts found matching category/search.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: discoverProv.posts.length,
                itemBuilder: (context, index) {
                  final post = discoverProv.posts[index];
                  return PostCard(
                    post: post,
                    onLike: () => discoverProv.toggleLike(post.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
