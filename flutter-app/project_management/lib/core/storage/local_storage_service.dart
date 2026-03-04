import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A thin wrapper around flutter_secure_storage used to persist the user role.
/// This keeps the role alongside the token in secure storage instead of using
/// plain shared preferences.
class LocalStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _roleKey = 'role';

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> clearRole() async {
    await _storage.delete(key: _roleKey);
  }
}
