// lib/services/auth_service.dart
class AuthService {
  // Simulasi database user (hanya disimpan di memori)
  static final List<Map<String, String>> _users = [];

  // Simulasi login
  static Future<bool> login(String email, String password) async {
    final user = _users.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
    return user.isNotEmpty;
  }

  // Simulasi register
  static Future<bool> register(String email, String password) async {
    final exists = _users.any((u) => u['email'] == email);
    if (exists) return false;

    _users.add({'email': email, 'password': password});
    return true;
  }
}