import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../../owner/data/owner_kos_remote_data_source.dart';
import '../../owner/data/owner_kos_repository.dart';
import '../../owner/presentation/owner_kos_list_screen.dart';
import '../../owner/providers/owner_kos_provider.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key, this.initialUser, this.successMessage});

  final User? initialUser;
  final String? successMessage;

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(widget.successMessage!)));
        }
      });
    }
  }

  Future<void> _logout(AuthProvider provider) async {
    final success = await provider.logout();
    if (!mounted) {
      return;
    }
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else if (provider.state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('logout-error'),
          content: Text(provider.state.errorMessage ?? 'Logout gagal.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider?>();
    final user = provider?.user ?? widget.initialUser;
    if (provider == null) {
      return const Scaffold(
        body: Center(child: Text('Konfigurasi autentikasi belum tersedia.')),
      );
    }

    final client = context.read<SupabaseClient?>();
    final repository = client == null
        ? null
        : OwnerKosRepository(SupabaseOwnerKosRemoteDataSource(client));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kos'),
        actions: [
          IconButton(
            key: const Key('logout-button'),
            onPressed: provider.isLoading ? null : () => _logout(provider),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: repository == null
          ? _OwnerConfigurationFallback(user: user)
          : ChangeNotifierProvider(
              create: (_) => OwnerKosProvider(
                repository: repository,
                authProvider: provider,
              ),
              child: const OwnerKosListScreen(),
            ),
    );
  }
}

class _OwnerConfigurationFallback extends StatelessWidget {
  const _OwnerConfigurationFallback({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kelola Kos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(user?.email ?? 'Pemilik sedang masuk'),
            const SizedBox(height: 12),
            const Text('Konfigurasi data kos belum tersedia.'),
          ],
        ),
      ),
    );
  }
}
