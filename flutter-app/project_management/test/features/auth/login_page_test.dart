import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_management/core/storage/local_storage_service.dart';
import 'package:project_management/core/storage/secure_storage_services.dart';
import 'package:project_management/features/auth/data/auth_repository.dart';
import 'package:project_management/features/auth/domain/auth_state.dart';
import 'package:project_management/features/auth/presentation/provider/auth_provider.dart';
import 'package:project_management/features/auth/presentation/view/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets('validates required fields before submitting', (tester) async {
      final notifier = _TestAuthNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.tap(find.byKey(LoginPageKeys.submitButton));
      await tester.pump();

      expect(notifier.loginRequests, isEmpty);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('submits trimmed credentials and shows loading state',
        (tester) async {
      final notifier = _TestAuthNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.enterText(
        find.byKey(LoginPageKeys.emailField),
        ' test@example.com ',
      );
      await tester.enterText(
        find.byKey(LoginPageKeys.passwordField),
        ' secret12 ',
      );

      await tester.tap(find.byKey(LoginPageKeys.submitButton));
      await tester.pump();

      expect(notifier.loginRequests.length, 1);
      expect(
        notifier.loginRequests.single,
        containsPair('email', 'test@example.com'),
      );
      expect(
        notifier.loginRequests.single,
        containsPair('password', 'secret12'),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier()
      : super(
          storage: _MemorySecureStorage(),
          localStorage: _MemoryLocalStorage(),
          repository: AuthRepository(Dio()),
        );

  final List<Map<String, String>> loginRequests = [];

  @override
  Future<void> login(String email, String password) async {
    loginRequests.add({'email': email, 'password': password});
    state = state.copyWith(status: AuthStatus.loading);
  }
}

class _MemorySecureStorage implements SecureStorageService {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}

class _MemoryLocalStorage implements LocalStorageService {
  String? _role;

  @override
  Future<void> saveRole(String role) async {
    _role = role;
  }

  @override
  Future<String?> getRole() async => _role;

  @override
  Future<void> clearRole() async {
    _role = null;
  }
}
