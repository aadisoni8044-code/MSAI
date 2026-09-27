import 'package:flutter/material.dart';
import './core/theme/app_theme.dart';
import './core/routes/app_routes.dart';
import './models/chat.dart';
import './models/community.dart';
import './models/status.dart';
import './screens/splash/splash_screen.dart';
import './screens/home/home_screen.dart';
import './screens/chat/individual_chat_screen.dart';
import './screens/chat/group_chat_screen.dart';
import './screens/chat/group_info_screen.dart';
import './screens/chat/media_preview_screen.dart';
import './screens/status/status_viewer_screen.dart';
import './screens/calls/call_active_screen.dart';
import './screens/communities/community_details_screen.dart';
import './screens/search/global_search_screen.dart';
import './screens/profile/user_profile_screen.dart';
import './screens/settings/settings_screen.dart';
import './screens/new_chat/new_chat_screen.dart';
import './screens/new_chat/new_group_screen.dart';

void main() {
  runApp(const ZipgramApp());
}

class ZipgramApp extends StatelessWidget {
  const ZipgramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZIPgram',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.chat:
            final chat = settings.arguments as Chat;
            return MaterialPageRoute(builder: (_) => IndividualChatScreen(chat: chat));
          case AppRoutes.groupChat:
            final chat = settings.arguments as Chat;
            return MaterialPageRoute(builder: (_) => GroupChatScreen(chat: chat));
          case AppRoutes.groupInfo:
            final chat = settings.arguments as Chat;
            return MaterialPageRoute(builder: (_) => GroupInfoScreen(chat: chat));
          case AppRoutes.mediaPreview:
            final url = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => MediaPreviewScreen(mediaUrl: url));
          case AppRoutes.statusViewer:
            final status = settings.arguments as Status;
            return MaterialPageRoute(builder: (_) => StatusViewerScreen(status: status));
          case AppRoutes.activeCall:
            final userName = settings.arguments as String? ?? 'Contact';
            return MaterialPageRoute(builder: (_) => CallActiveScreen(userName: userName));
          case AppRoutes.communityDetails:
            final community = settings.arguments as Community;
            return MaterialPageRoute(builder: (_) => CommunityDetailsScreen(community: community));
          case AppRoutes.search:
            return MaterialPageRoute(builder: (_) => const GlobalSearchScreen());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const UserProfileScreen());
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case AppRoutes.newChat:
            return MaterialPageRoute(builder: (_) => const NewChatScreen());
          case AppRoutes.newGroup:
            return MaterialPageRoute(builder: (_) => const NewGroupScreen());
          default:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      },
    );
  }
}
