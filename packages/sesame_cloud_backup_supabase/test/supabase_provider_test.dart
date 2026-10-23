import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/src/supabase_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseProvider', () {
    late SupabaseProvider provider;

    setUp(() {
      provider = SupabaseProvider();
    });

    test('validateConfig should return false for empty config', () {
      expect(provider.validateConfig({}), isFalse);
    });

    test('validateConfig should return false for missing url', () {
      expect(
        provider.validateConfig({'anonKey': 'key'}),
        isFalse,
      );
    });

    test('validateConfig should return false for missing anonKey', () {
      expect(
        provider.validateConfig({'url': 'https://example.com'}),
        isFalse,
      );
    });

    test('validateConfig should return true for valid config', () {
      expect(
        provider.validateConfig({
          'url': 'https://example.supabase.co',
          'anonKey': 'test-key',
        }),
        isTrue,
      );
    });

    test('validateConfig should accept optional bucket', () {
      expect(
        provider.validateConfig({
          'url': 'https://example.supabase.co',
          'anonKey': 'test-key',
          'bucket': 'user-data',
        }),
        isTrue,
      );
    });

    test('validateConfig should return false for invalid bucket type', () {
      expect(
        provider.validateConfig({
          'url': 'https://example.supabase.co',
          'anonKey': 'test-key',
          'bucket': 123, // should be string
        }),
        isFalse,
      );
    });

    test(
        'should throw CloudConfigurationException when accessing storage before initialization',
        () {
      expect(
        () => provider.storage,
        throwsA(isA<CloudConfigurationException>()),
      );
    });

    test('initialize should throw on invalid config', () async {
      expect(
        () => provider.initialize({}),
        throwsA(isA<CloudConfigurationException>()),
      );
    });

    // Note: Full integration tests require a real Supabase instance
    // and should be run separately with proper credentials
  });
}
