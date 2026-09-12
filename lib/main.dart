import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/call_service.dart';
import 'services/contact_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'models/chat_model.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/chats_tab.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/calls_tab.dart';
import 'screens/call_screen.dart';
import 'screens/contacts_tab.dart';
import 'screens/settings_tab.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const ZipgramApp());
}

class ZipgramApp extends StatefulWidget {
  const ZipgramApp({super.key});

  @override
  State<ZipgramApp> createState() => _ZipgramAppState();
}

class _ZipgramAppState extends State<ZipgramApp> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  final ContactService _contactService = ContactService();
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsService,
      builder: (context, _) {
        return MaterialApp(
          title: 'ZIPGRAM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: !_isInitialized
              ? SplashScreen(
                  onFinish: () => setState(() => _isInitialized = true),
                )
              : ListenableBuilder(
                  listenable: _authService,
                  builder: (context, _) {
                    if (!_authService.isAuthenticated) {
                      return AuthFlowNavigator(authService: _authService);
                    }
                    return MainContainer(
                      authService: _authService,
                      chatService: _chatService,
                      callService: _callService,
                      contactService: _contactService,
                      settingsService: _settingsService,
                      notificationService: _notificationService,
                    );
                  },
                ),
        );
      },
    );
  }
}

class AuthFlowNavigator extends StatefulWidget {
  final AuthService authService;
  const AuthFlowNavigator({super.key, required this.authService});

  @override
  State<AuthFlowNavigator> createState() => _AuthFlowNavigatorState();
}

class _AuthFlowNavigatorState extends State<AuthFlowNavigator> {
  String _currentStep = 'welcome'; // welcome, login, signup

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 'login':
        return LoginScreen(
          authService: widget.authService,
          onLoginSuccess: () {},
          onGoToSignUp: () => setState(() => _currentStep = 'signup'),
        );
      case 'signup':
        return SignUpScreen(
          authService: widget.authService,
          onSignUpSuccess: () {},
          onGoToLogin: () => setState(() => _currentStep = 'login'),
        );
      default:
        return WelcomeScreen(
          onLoginPressed: () => setState(() => _currentStep = 'login'),
          onSignUpPressed: () => setState(() => _currentStep = 'signup'),
        );
    }
  }
}

class MainContainer extends StatefulWidget {
  final AuthService authService;
  final ChatService chatService;
  final CallService callService;
  final ContactService contactService;
  final SettingsService settingsService;
  final NotificationService notificationService;

  const MainContainer({
    super.key,
    required this.authService,
    required this.chatService,
    required this.callService,
    required this.contactService,
    required this.settingsService,
    required this.notificationService,
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  void _openChatDetail(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chat: chat,
          chatService: widget.chatService,
          callService: widget.callService,
          onStartCall: _openActiveCall,
        ),
      ),
    );
  }

  void _openActiveCall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(callService: widget.callService),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          authService: widget.authService,
          onLogout: () {},
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          chatService: widget.chatService,
          contactService: widget.contactService,
          onChatSelected: _openChatDetail,
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          notificationService: widget.notificationService,
        ),
      ),
    );
  }

  void _openNewChatDialog() {
    final contacts = widget.contactService.contacts;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Start New Conversation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index].user;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withAlpha(40),
                        child: Text(contact.name[0]),
                      ),
                      title: Text(contact.name),
                      subtitle: Text('@${contact.username}'),
                      onTap: () {
                        Navigator.pop(context);
                        final chat = widget.chatService.startNewChatWithUser(contact);
                        _openChatDetail(chat);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['ZIPGRAM', 'Calls', 'Contacts', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primaryBlueLight),
            onPressed: _openSearch,
          ),
          ListenableBuilder(
            listenable: widget.notificationService,
            builder: (context, _) {
              final unread = widget.notificationService.unreadCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primaryBlueLight),
                    onPressed: _openNotifications,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.missedCallRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChatsTab(
            chatService: widget.chatService,
            onChatSelected: _openChatDetail,
            onNewChatPressed: _openNewChatDialog,
          ),
          CallsTab(
            callService: widget.callService,
            onStartCall: _openActiveCall,
          ),
          ContactsTab(
            contactService: widget.contactService,
            chatService: widget.chatService,
            callService: widget.callService,
            onStartChatWithUser: (user) {
              final chat = widget.chatService.startNewChatWithUser(user);
              _openChatDetail(chat);
            },
            onStartCall: _openActiveCall,
          ),
          SettingsTab(
            settingsService: widget.settingsService,
            authService: widget.authService,
            onOpenProfile: _openProfile,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openNewChatDialog,
              child: const Icon(Icons.chat_rounded),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_outlined),
            activeIcon: Icon(Icons.phone_rounded),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            activeIcon: Icon(Icons.contacts_rounded),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
