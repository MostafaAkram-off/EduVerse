enum UserRole {
  student('student'),
  instructor('instructor');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) =>
      UserRole.values.firstWhere((r) => r.value == value,
          orElse: () => UserRole.student);
}
