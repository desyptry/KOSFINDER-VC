import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder_vc/core/config/app_config.dart';

void main() {
  test('rejects missing Supabase configuration', () {
    const config = AppConfig(supabaseUrl: '', supabaseAnonKey: '');

    expect(config.isValid, isFalse);
    expect(config.validate, throwsStateError);
  });

  test('accepts configuration supplied at runtime', () {
    const config = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      supabaseAnonKey: 'example-anon-key',
    );

    expect(config.isValid, isTrue);
    expect(config.validate, returnsNormally);
  });
}
