// user_data.dart
// Simulasi database sederhana pakai Map
class UserData {
  static final Map<String, String> _users = {};

  static void register(String email, String password) {
    _users[email] = password;
  }

  static bool login(String email, String password) {
    return _users.containsKey(email) && _users[email] == password;
  }
}