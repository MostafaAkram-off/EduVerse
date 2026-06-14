import 'dart:convert';

/// Decodes a JWT token and extracts ASP.NET Identity claims.
class JwtDecoder {
  JwtDecoder._();

  // ASP.NET long-form claim URIs
  static const _nameId =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  static const _emailClaim =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
  static const _nameClaim =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
  static const _roleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    try {
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static String getUserId(Map<String, dynamic> c) =>
      (c[_nameId] ?? c['sub'] ?? '') as String;

  static String getEmail(Map<String, dynamic> c) =>
      (c[_emailClaim] ?? c['email'] ?? '') as String;

  static String getUserName(Map<String, dynamic> c) =>
      (c[_nameClaim] ?? c['unique_name'] ?? c['name'] ?? '') as String;

  static String getRole(Map<String, dynamic> c) =>
      (c[_roleClaim] ?? c['role'] ?? 'Student') as String;

  static String getFullName(Map<String, dynamic> c) =>
      (c['FullName'] ?? '') as String;

  static bool isExpired(Map<String, dynamic> c) {
    final exp = c['exp'];
    if (exp == null) return true;
    final expiry =
        DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiry);
  }
}
