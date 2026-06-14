import 'package:edu_verse/features/auth/shared/user_data.dart';

/// Lightweight in-memory session holder.
/// Set after login, cleared on logout.
class AuthSession {
  AuthSession._();

  static UserData? _current;
  static String? _token;
  static String? _refreshToken;

  static UserData? get current => _current;
  static String? get token => _token;
  static String? get refreshToken => _refreshToken;

  static void set(
    UserData user, {
    required String token,
    String? refreshToken,
  }) {
    _current = user;
    _token = token;
    _refreshToken = refreshToken;
  }

  static void clear() {
    _current = null;
    _token = null;
    _refreshToken = null;
  }

  static String get name => _current?.name ?? 'User';
  static String get fullName => _current?.fullName ?? name;
  static String get email => _current?.email ?? '';
  static String get id => _current?.id ?? '';
}
