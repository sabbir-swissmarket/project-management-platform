import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/auth_state.dart';
import '../provider/auth_provider.dart';

class LoginPageKeys {
  static const emailField = ValueKey('login_email_field');
  static const passwordField = ValueKey('login_password_field');
  static const submitButton = ValueKey('login_submit_button');
  static const errorText = ValueKey('login_error_text');
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ProviderSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual<AuthState>(
      authProvider,
      _handleAuthStateChange,
    );
  }

  @override
  void dispose() {
    _authSubscription.close();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    FocusScope.of(context).unfocus();

    ref.read(authProvider.notifier).login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final isLoading = authState.status == AuthStatus.loading;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(blurRadius: 20, color: Colors.black26),
              ],
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          key: LoginPageKeys.emailField,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: LoginPageKeys.passwordField,
                          controller: passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Use at least 6 characters";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: LoginPageKeys.submitButton,
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
                    ),
                  ),
                  if (authState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        key: LoginPageKeys.errorText,
                        authState.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuthStateChange(AuthState? previous, AuthState next) {
    if (!mounted) return;

    final movedToAuthenticated = next.status == AuthStatus.authenticated &&
        previous?.status != AuthStatus.authenticated;
    if (!movedToAuthenticated) return;

    switch (next.role) {
      case "admin":
        context.go('/admin');
        break;
      case "buyer":
        context.go('/buyer');
        break;
      case "developer":
        context.go('/developer');
        break;
      default:
        break;
    }
  }
}
