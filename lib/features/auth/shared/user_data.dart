import 'package:edu_verse/features/auth/shared/user_role.dart';

class UserData {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isVerified;

  const UserData({
    required this.id,
    required this.name,
    this.fullName = '',
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id:         json['id'] as String? ?? '',
      name:       json['userName'] as String? ?? json['name'] as String? ?? '',
      fullName:   json['fullName'] as String? ?? json['FullName'] as String? ?? '',
      email:      json['email'] as String? ?? '',
      phone:      json['phone'] as String?,
      role:       UserRole.fromString(json['role'] as String? ?? 'Student'),
      avatarUrl:  json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      isVerified: json['isVerified'] as bool? ?? json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'userName':  name,
    'fullName':  fullName,
    'email':     email,
    'phone':     phone,
    'role':      role.value,
    'avatarUrl': avatarUrl,
    'isVerified': isVerified,
  };
}
