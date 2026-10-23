import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_webdav/src/webdav_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebDAVProvider', () {
    late WebDAVProvider provider;

    setUp(() {
      provider = WebDAVProvider();
    });

    test('validateConfig should return false for empty config', () {
      expect(provider.validateConfig({}), isFalse);
    });

    test('validateConfig should return false for missing url', () {
      expect(
        provider.validateConfig({
          'username': 'user',
          'password': 'pass',
        }),
        isFalse,
      );
    });

    test('validateConfig should return false for missing username', () {
      expect(
        provider.validateConfig({
          'url': 'https://example.com',
          'password': 'pass',
        }),
        isFalse,
      );
    });

    test('validateConfig should return false for missing password', () {
      expect(
        provider.validateConfig({
          'url': 'https://example.com',
          'username': 'user',
        }),
        isFalse,
      );
    });

    test('validateConfig should return true for valid config', () {
      expect(
        provider.validateConfig({
          'url': 'https://nextcloud.example.com',
          'username': 'user@example.com',
          'password': 'password',
        }),
        isTrue,
      );
    });

    test('validateConfig should accept optional remotePath', () {
      expect(
        provider.validateConfig({
          'url': 'https://nextcloud.example.com',
          'username': 'user@example.com',
          'password': 'password',
          'remotePath': '/SesameNotes/',
        }),
        isTrue,
      );
    });

    test('validateConfig should return false for invalid remotePath type', () {
      expect(
        provider.validateConfig({
          'url': 'https://nextcloud.example.com',
          'username': 'user@example.com',
          'password': 'password',
          'remotePath': 123, // should be string
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

    // Note: Full integration tests require a real WebDAV server
    // and should be run separately with proper credentials
  });
}
