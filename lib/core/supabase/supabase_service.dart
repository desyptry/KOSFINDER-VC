import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

Future<SupabaseClient> initializeSupabase(AppConfig config) async {
  config.validate();

  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabaseAnonKey,
  );

  return Supabase.instance.client;
}
