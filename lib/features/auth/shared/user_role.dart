enum UserRole {
  student('Student'),
  instructor('Instructor');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) => UserRole.values.firstWhere(
        (r) => r.value.toLowerCase() == value.toLowerCase(),
        orElse: () => UserRole.student,
      );
}
