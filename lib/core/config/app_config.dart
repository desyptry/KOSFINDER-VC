class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get isValid =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  void validate() {
    if (!isValid) {
      throw StateError(
        'Supabase configuration is missing. Run with '
        '--dart-define=SUPABASE_URL=... and '
        '--dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }
}
