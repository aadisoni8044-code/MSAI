import '../models/user_model.dart';

abstract class UserRepository {
  Future<List<UserModel>> getContacts();
  Future<UserModel?> getUserById(String id);
  Future<UserModel> updateProfile({required String name, required String about, String? avatarUrl});
  Future<List<UserModel>> searchUsers(String query);
}
