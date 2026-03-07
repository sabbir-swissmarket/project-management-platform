enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? role;
  final String? token;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.role,
    this.token,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? role,
    String? token,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      role: role ?? this.role,
      token: token ?? this.token,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
