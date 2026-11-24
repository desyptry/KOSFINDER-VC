import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_login_screen.dart';
import '../features/auth/presentation/auth_register_screen.dart';
import '../features/auth/presentation/owner_home_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/kos/data/kos_remote_data_source.dart';
import '../features/kos/data/kos_repository.dart';
import '../features/kos/presentation/kos_list_screen.dart';

class KosFinderApp extends StatelessWidget {
  KosFinderApp({
    super.key,
    this.supabaseClient,
    this.kosRepository,
    this.authRepository,
  });

  final SupabaseClient? supabaseClient;
  final KosRepository? kosRepository;
  final AuthRepository? authRepository;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final repository =
        kosRepository ??
        (supabaseClient == null
            ? null
            : KosRepository(SupabaseKosRemoteDataSource(supabaseClient!)));
    final resolvedAuthRepository =
        authRepository ??
        (supabaseClient == null ? null : AuthRepository(supabaseClient!));

    final app = MaterialApp(
      title: 'KosFinder',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const KosListScreen(),
        '/about': (_) => const AboutScreen(),
        '/auth/login': (_) => const AuthLoginScreen(),
        '/auth/register': (_) => const AuthRegisterScreen(),
        '/owner': (_) => const OwnerHomeScreen(),
      },
      builder: (context, child) =>
          _AppShellOverlay(navigatorKey: _navigatorKey, child: child!),
    );

    if (repository == null && resolvedAuthRepository == null) {
      return app;
    }

    return MultiProvider(
      providers: [
        if (supabaseClient != null)
          Provider<SupabaseClient>.value(value: supabaseClient!),
        if (repository != null)
          Provider<KosRepository>.value(value: repository),
        if (resolvedAuthRepository != null)
          ChangeNotifierProvider(
            create: (_) => AuthProvider(resolvedAuthRepository),
          ),
      ],
      child: app,
    );
  }
}

class _AppShellOverlay extends StatelessWidget {
  const _AppShellOverlay({required this.child, required this.navigatorKey});

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          right: 56,
          child: SafeArea(
            child: _OwnerAccessButton(
              onPressed: () {
                final provider = context.read<AuthProvider?>();
                final route = provider?.session != null
                    ? '/owner'
                    : '/auth/login';
                navigatorKey.currentState?.pushNamed(route);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerAccessButton extends StatelessWidget {
  const _OwnerAccessButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const Key('owner-access-button'),
      onPressed: onPressed,
      icon: const Icon(Icons.person_outline),
      label: const Text('Masuk sebagai Pemilik'),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('2415051002 - Luh Desy Putri Yanti')),
    );
  }
}
