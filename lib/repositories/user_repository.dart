import '../models/user.dart';

class UserRepository {
  final List<User> _demoUsers = [
    const User(
      id: 'usr_1',
      name: 'Aarav Sharma',
      phone: '+91 98765 43210',
      email: 'aarav@example.com',
      about: 'Available for quick chat 🚀',
      isOnline: true,
    ),
    const User(
      id: 'usr_2',
      name: 'Sofia Rodriguez',
      phone: '+1 555 019 2831',
      email: 'sofia@example.com',
      about: 'Building cool Flutter apps!',
      isOnline: false,
    ),
    const User(
      id: 'usr_3',
      name: 'MSAI Support',
      phone: '+1 800 555 0199',
      email: 'support@msai.com',
      about: 'Official MSAI Assistant',
      isOnline: true,
    ),
  ];

  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return _demoUsers;
    return _demoUsers.where((u) =>
      u.name.toLowerCase().contains(query.toLowerCase()) ||
      u.phone.contains(query) ||
      u.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<User?> getUserById(String id) async {
    try {
      return _demoUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    // Backend call to block target user
  }

  Future<void> reportUser(String targetUserId, String reason) async {
    // Backend call to report target user
  }
}
