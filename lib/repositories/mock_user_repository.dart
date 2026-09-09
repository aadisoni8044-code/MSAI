import '../models/user_model.dart';
import 'user_repository.dart';

class MockUserRepository implements UserRepository {
  final List<UserModel> _mockContacts = [
    const UserModel(
      id: 'user_1',
      name: 'Sarah Connor',
      phoneNumber: '+1 555-0101',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      about: 'Living life one day at a time ✨',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_2',
      name: 'David Miller',
      phoneNumber: '+1 555-0102',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=300&q=80',
      about: 'In a meeting 💼',
      isOnline: false,
    ),
    const UserModel(
      id: 'user_3',
      name: 'Emma Watson',
      phoneNumber: '+1 555-0103',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=300&q=80',
      about: 'At work ☕',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_4',
      name: 'Michael Brown',
      phoneNumber: '+1 555-0104',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      about: 'Urgent calls only 📞',
      isOnline: false,
    ),
    const UserModel(
      id: 'user_5',
      name: 'Sophia Martinez',
      phoneNumber: '+1 555-0105',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=300&q=80',
      about: 'Battery about to die 🔋',
      isOnline: true,
    ),
  ];

  @override
  Future<List<UserModel>> getContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockContacts);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockContacts.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String about,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserModel(
      id: 'user_me',
      name: name,
      phoneNumber: '+1 555-0199',
      about: about,
      avatarUrl: avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      isOnline: true,
    );
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.trim().isEmpty) return _mockContacts;
    final lq = query.toLowerCase();
    return _mockContacts.where((u) =>
      u.name.toLowerCase().contains(lq) || u.phoneNumber.contains(lq) || u.about.toLowerCase().contains(lq)
    ).toList();
  }
}
