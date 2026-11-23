import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/kos/data/kos_remote_data_source.dart';
import '../features/kos/data/kos_repository.dart';
import '../features/kos/presentation/kos_list_screen.dart';

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key, this.supabaseClient, this.kosRepository});

  final SupabaseClient? supabaseClient;
  final KosRepository? kosRepository;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'KosFinder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const KosListScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );

    if (supabaseClient == null && kosRepository == null) {
      return app;
    }

    final repository =
        kosRepository ??
        KosRepository(SupabaseKosRemoteDataSource(supabaseClient!));

    return MultiProvider(
      providers: [
        if (supabaseClient != null)
          Provider<SupabaseClient>.value(value: supabaseClient!),
        Provider<KosRepository>.value(value: repository),
      ],
      child: app,
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
