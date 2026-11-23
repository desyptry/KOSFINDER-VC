import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/kos_finder_app.dart';
import 'core/config/app_config.dart';
import 'core/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final client = await initializeSupabase(config);

  runApp(MyApp(supabaseClient: client));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.supabaseClient});

  final SupabaseClient? supabaseClient;

  @override
  Widget build(BuildContext context) {
    return KosFinderApp(supabaseClient: supabaseClient);
  }
}
