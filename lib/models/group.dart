class Group {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<String> adminIds;
  final bool onlyAdminsCanSend;
  final bool onlyAdminsCanEditInfo;

  const Group({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    required this.createdBy,
    required this.createdAt,
    required this.memberIds,
    required this.adminIds,
    this.onlyAdminsCanSend = false,
    this.onlyAdminsCanEditInfo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'adminIds': adminIds,
      'onlyAdminsCanSend': onlyAdminsCanSend,
      'onlyAdminsCanEditInfo': onlyAdminsCanEditInfo,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      memberIds: List<String>.from(json['memberIds'] as List? ?? []),
      adminIds: List<String>.from(json['adminIds'] as List? ?? []),
      onlyAdminsCanSend: json['onlyAdminsCanSend'] as bool? ?? false,
      onlyAdminsCanEditInfo: json['onlyAdminsCanEditInfo'] as bool? ?? true,
    );
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    List<String>? adminIds,
    bool? onlyAdminsCanSend,
    bool? onlyAdminsCanEditInfo,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      onlyAdminsCanSend: onlyAdminsCanSend ?? this.onlyAdminsCanSend,
      onlyAdminsCanEditInfo: onlyAdminsCanEditInfo ?? this.onlyAdminsCanEditInfo,
    );
  }
}
