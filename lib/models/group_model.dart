import 'user_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String adminId;
  final List<String> memberIds;
  final List<UserModel> members;
  final DateTime createdAt;
  final bool isMuted;

  const GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.avatarUrl,
    required this.adminId,
    required this.memberIds,
    this.members = const [],
    required this.createdAt,
    this.isMuted = false,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? adminId,
    List<String>? memberIds,
    List<UserModel>? members,
    DateTime? createdAt,
    bool? isMuted,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      adminId: adminId ?? this.adminId,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'adminId': adminId,
      'memberIds': memberIds,
      'members': members.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isMuted': isMuted,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String,
      adminId: json['adminId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      members: (json['members'] as List?)
              ?.map((m) => UserModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isMuted: json['isMuted'] as bool? ?? false,
    );
  }
}
