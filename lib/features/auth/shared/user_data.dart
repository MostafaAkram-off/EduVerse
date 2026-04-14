import 'package:edu_verse/features/auth/shared/user_role.dart';

class UserData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isVerified;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id:         json['id'] as String? ?? '',
      name:       json['name'] as String? ?? '',
      email:      json['email'] as String? ?? '',
      phone:      json['phone'] as String?,
      role:       UserRole.fromString(json['role'] as String? ?? 'student'),
      avatarUrl:  json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'email':       email,
    'phone':       phone,
    'role':        role.value,
    'avatar_url':  avatarUrl,
    'is_verified': isVerified,
  };
}
