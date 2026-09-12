import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';

class ContactService extends ChangeNotifier {
  List<ContactItem> _contacts = [];

  ContactService() {
    _initDemoData();
  }

  List<ContactItem> get contacts => _contacts;

  void _initDemoData() {
    final now = DateTime.now();

    final rawUsers = [
      User(
        id: 'user_3',
        name: 'Emma Watson',
        username: 'emmaw',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        bio: 'Coffee, Code & Creativity ☕🎨',
        phone: '+1 (555) 345-6789',
        status: UserStatus.offline,
        lastSeen: now.subtract(const Duration(minutes: 42)),
      ),
      User(
        id: 'user_2',
        name: 'Liam Chen',
        username: 'liamc',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        bio: 'Mobile Dev & Flutter fan 🚀',
        phone: '+1 (555) 876-5432',
        status: UserStatus.online,
        lastSeen: now,
      ),
      User(
        id: 'user_4',
        name: 'Marcus Vance',
        username: 'marcusv',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        bio: 'Product Strategist',
        phone: '+1 (555) 456-7890',
        status: UserStatus.away,
        lastSeen: now.subtract(const Duration(hours: 3)),
      ),
      User(
        id: 'user_5',
        name: 'Noah Williams',
        username: 'noahw',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        bio: 'UI Designer & Photographer',
        phone: '+1 (555) 567-8901',
        status: UserStatus.online,
        lastSeen: now,
      ),
      User(
        id: 'user_1',
        name: 'Sophia Vance',
        username: 'sophiav',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        bio: 'Design lead @ ZIPGRAM | Tech enthusiast',
        phone: '+1 (555) 234-5678',
        status: UserStatus.online,
        lastSeen: now,
      ),
      User(
        id: 'user_6',
        name: 'Zoe Martinez',
        username: 'zoem',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        bio: 'Software Architect',
        phone: '+1 (555) 678-9012',
        status: UserStatus.offline,
        lastSeen: now.subtract(const Duration(days: 1)),
      ),
    ];

    rawUsers.sort((a, b) => a.name.compareTo(b.name));

    _contacts = rawUsers.map((u) {
      final header = u.name.isNotEmpty ? u.name[0].toUpperCase() : '#';
      return ContactItem(user: u, categoryHeader: header);
    }).toList();
  }

  void addContact(String name, String username, String phone, {String? bio}) {
    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      username: username,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      bio: bio ?? 'Hey there! I am using ZIPGRAM.',
      phone: phone,
      status: UserStatus.online,
      lastSeen: DateTime.now(),
    );

    final header = name.isNotEmpty ? name[0].toUpperCase() : '#';
    _contacts.add(ContactItem(user: newUser, categoryHeader: header));
    _contacts.sort((a, b) => a.user.name.compareTo(b.user.name));
    notifyListeners();
  }
}
