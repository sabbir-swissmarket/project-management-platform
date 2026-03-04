import 'package:flutter_riverpod/legacy.dart';

import '../../../../../core/network/dio_provider.dart';
import '../../../../../core/utils/jwt_decoder.dart';
import '../../../../core/storage/secure_storage_services.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final _storage = SecureStorageService();
  final _dio = DioProvider.createDio();

  Future<void> checkAuth() async {
    final token = await _storage.getToken();

    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    final role = JwtDecoder.getRole(token);

    state = state.copyWith(status: AuthStatus.authenticated, role: role);
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final repo = AuthRepository(_dio);
      final token = await repo.login(email, password);

      await _storage.saveToken(token);

      final role = JwtDecoder.getRole(token);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        role: role,
        token: token,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: "Login failed",
      );
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();

    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
