import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'auth_register_screen.dart';
import 'owner_home_screen.dart';

class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider provider) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await provider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted || !success || provider.session == null) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OwnerHomeScreen(initialUser: provider.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider?>();
    if (provider == null) {
      return const _AuthConfigurationError();
    }

    final state = provider.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk Pemilik')),
      body: _AuthForm(
        formKey: _formKey,
        emailController: _emailController,
        passwordController: _passwordController,
        submitLabel: 'Masuk',
        isLoading: provider.isLoading,
        errorMessage: state.status == AuthStatus.error
            ? state.errorMessage
            : null,
        onSubmit: () => _submit(provider),
        footer: TextButton(
          onPressed: provider.isLoading
              ? null
              : () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AuthRegisterScreen(),
                  ),
                ),
          child: const Text('Belum punya akun? Daftar'),
        ),
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.submitLabel,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.footer,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String submitLabel;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('auth-email'),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('auth-password'),
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: _requiredValidator,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    key: const Key('auth-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: Key('auth-submit-$submitLabel'),
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(submitLabel),
                ),
                footer,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email dan password wajib diisi.';
  }
  return null;
}

class _AuthConfigurationError extends StatelessWidget {
  const _AuthConfigurationError();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Konfigurasi autentikasi belum tersedia.')),
    );
  }
}
