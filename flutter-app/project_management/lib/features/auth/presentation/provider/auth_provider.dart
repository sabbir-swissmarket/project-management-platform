import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../../core/network/dio_provider.dart';
import '../../../../../core/utils/jwt_decoder.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_services.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    SecureStorageService? storage,
    LocalStorageService? localStorage,
    AuthRepository? repository,
  })  : _storage = storage ?? SecureStorageService(),
        _local = localStorage ?? LocalStorageService(),
        _repository = repository ?? AuthRepository(DioProvider.createDio()),
        super(AuthState());

  final SecureStorageService _storage;
  final LocalStorageService _local;
  final AuthRepository _repository;

  Future<void> checkAuth() async {
    final token = await _storage.getToken();

    if (token == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      );
      return;
    }

    // prefer stored role so we don't need to decode every time
    String? role = await _local.getRole();
    if (role == null) {
      role = JwtDecoder.getRole(token);
      await _local.saveRole(role);
    }

    state = state.copyWith(
      status: AuthStatus.authenticated,
      role: role,
      token: token,
      clearError: true,
    );
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
      );

      final token = await _repository.login(email, password);

      await _storage.saveToken(token);

      final role = JwtDecoder.getRole(token);
      await _local.saveRole(role);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: role,
        token: token,
        clearError: true,
      );
    } catch (e) {
      debugPrint("Login error: $e");
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: "Login failed",
      );
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    await _local.clearRole();

    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
