class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isEmailVerified;
  final String? photoUrl;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isEmailVerified = false,
    this.photoUrl,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
