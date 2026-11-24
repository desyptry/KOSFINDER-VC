import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import 'auth_login_screen.dart';
import 'owner_home_screen.dart';

class AuthRegisterScreen extends StatefulWidget {
  const AuthRegisterScreen({super.key});

  @override
  State<AuthRegisterScreen> createState() => _AuthRegisterScreenState();
}

class _AuthRegisterScreenState extends State<AuthRegisterScreen> {
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

    final success = await provider.register(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted || !success || provider.session == null) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OwnerHomeScreen(
          initialUser: provider.user,
          successMessage: 'Pendaftaran berhasil.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider?>();
    if (provider == null) {
      return const _RegisterConfigurationError();
    }

    final state = provider.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pemilik')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('auth-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('auth-password'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: _requiredValidator,
                  ),
                  if (state.status == AuthStatus.error) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Pendaftaran gagal.',
                      key: const Key('auth-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('auth-submit-Daftar'),
                    onPressed: provider.isLoading
                        ? null
                        : () => _submit(provider),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Daftar'),
                  ),
                  TextButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const AuthLoginScreen(),
                            ),
                          ),
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ],
              ),
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

class _RegisterConfigurationError extends StatelessWidget {
  const _RegisterConfigurationError();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Konfigurasi autentikasi belum tersedia.')),
    );
  }
}
