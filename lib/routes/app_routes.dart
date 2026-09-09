import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chats/chats_screen.dart';
import '../screens/chat/individual_chat_screen.dart';
import '../screens/chat/group_chat_screen.dart';
import '../screens/contacts/contacts_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/status/status_stories_screen.dart';
import '../screens/media/media_gallery_screen.dart';
import '../screens/media/camera_media_picker_screen.dart';
import '../screens/groups/group_info_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String chats = '/chats';
  static const String individualChat = '/individual-chat';
  static const String groupChat = '/group-chat';
  static const String contacts = '/contacts';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String privacySettings = '/privacy-settings';
  static const String notificationSettings = '/notification-settings';
  static const String statusStories = '/status-stories';
  static const String mediaGallery = '/media-gallery';
  static const String cameraMediaPicker = '/camera-media-picker';
  static const String groupInfo = '/group-info';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registration:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case otp:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(phoneNumber: args['phoneNumber'] ?? ''),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case chats:
        return MaterialPageRoute(builder: (_) => const ChatsScreen());
      case individualChat:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => IndividualChatScreen(
            chatRoomId: args['chatRoomId'] ?? '',
            title: args['title'] ?? 'Chat',
            avatarUrl: args['avatarUrl'] ?? '',
            receiverId: args['receiverId'] ?? '',
          ),
        );
      case groupChat:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(
            groupId: args['groupId'] ?? '',
            groupName: args['groupName'] ?? 'Group',
            groupAvatarUrl: args['groupAvatarUrl'] ?? '',
          ),
        );
      case contacts:
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const GlobalSearchScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case privacySettings:
        return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());
      case notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      case statusStories:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => StatusStoriesScreen(statusModel: args['statusModel']),
        );
      case mediaGallery:
        return MaterialPageRoute(builder: (_) => const MediaGalleryScreen());
      case cameraMediaPicker:
        return MaterialPageRoute(builder: (_) => const CameraMediaPickerScreen());
      case groupInfo:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => GroupInfoScreen(groupId: args['groupId'] ?? ''),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
