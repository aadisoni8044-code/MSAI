import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/glass_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/navigation_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
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
                      'CHAT',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.black,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GlassTheme.glassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 20,
                        child: const Icon(
                          FontAwesomeIcons.userPlus,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassTheme.glassContainer(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 20,
                        child: const Icon(
                          FontAwesomeIcons.ellipsisVertical,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: GlassTheme.glassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 18,
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search friends & snaps...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Conversations List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProv, child) {
                  final conversations = chatProv.conversations;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final chat = conversations[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GlassTheme.glassContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 20,
                          child: Row(
                            children: [
                              // Avatar with Online Status Indicator
                              Stack(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: chat.unreadCount > 0
                                            ? AppColors.accent
                                            : AppColors.glassBorder,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(chat.avatar),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (chat.isOnline)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.onlineGlow,
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Name and Last Message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          chat.name,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          chat.time,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          chat.unreadCount > 0
                                              ? FontAwesomeIcons.bolt
                                              : FontAwesomeIcons.checkDouble,
                                          color: chat.unreadCount > 0
                                              ? AppColors.accent
                                              : AppColors.textMuted,
                                          size: 11,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            chat.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: chat.unreadCount > 0
                                                  ? AppColors.accent
                                                  : AppColors.textSecondary,
                                              fontSize: 13,
                                              fontWeight: chat.unreadCount > 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Camera Quick Snap Button
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.camera,
                                    color: AppColors.accent,
                                    size: 14,
                                  ),
                                ),
                                onPressed: () {
                                  context.read<NavigationProvider>().goToCamera();
                                },
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
          ],
        ),
      ),
    );
  }
}
