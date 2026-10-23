import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PathHelper - normalize', () {
    test('should remove leading slashes', () {
      expect(PathHelper.normalize('/users/123/data.json'),
          equals('users/123/data.json'));
      expect(PathHelper.normalize('//users/123/data.json'),
          equals('users/123/data.json'));
      expect(PathHelper.normalize('///users/123/data.json'),
          equals('users/123/data.json'));
    });

    test('should remove trailing slashes', () {
      expect(PathHelper.normalize('users/123/data.json/'),
          equals('users/123/data.json'));
      expect(PathHelper.normalize('users/123/data.json//'),
          equals('users/123/data.json'));
    });

    test('should replace multiple slashes with single slash', () {
      expect(PathHelper.normalize('users//123///data.json'),
          equals('users/123/data.json'));
    });

    test('should handle empty string', () {
      expect(PathHelper.normalize(''), equals(''));
    });

    test('should handle single segment', () {
      expect(PathHelper.normalize('data.json'), equals('data.json'));
      expect(PathHelper.normalize('/data.json'), equals('data.json'));
    });
  });

  group('PathHelper - join', () {
    test('should join multiple segments', () {
      expect(PathHelper.join(['users', '123', 'data.json']),
          equals('users/123/data.json'));
    });

    test('should normalize joined path', () {
      expect(PathHelper.join(['users/', '/123/', '/data.json']),
          equals('users/123/data.json'));
      expect(PathHelper.join(['//users', '123//', 'data.json']),
          equals('users/123/data.json'));
    });

    test('should handle empty list', () {
      expect(PathHelper.join([]), equals(''));
    });

    test('should handle single segment', () {
      expect(PathHelper.join(['data.json']), equals('data.json'));
    });

    test('用户目录片段按相对对象路径拼接，空后缀和重复斜杠均保持规范', () {
      expect(PathHelper.join(['users', 'user123', 'ledgers', '456.json']),
          equals('users/user123/ledgers/456.json'));
      expect(PathHelper.join(['users', 'abc', 'data.json']),
          equals('users/abc/data.json'));
      expect(PathHelper.join(['users', 'user123']), equals('users/user123'));
      expect(PathHelper.join(['users', 'user123', '/ledgers/', '//456.json']),
          equals('users/user123/ledgers/456.json'));
    });
  });

  group('PathHelper - dirname', () {
    test('should return parent directory', () {
      expect(PathHelper.dirname('users/123/data.json'), equals('users/123'));
      expect(PathHelper.dirname('users/123/'), equals('users'));
      expect(PathHelper.dirname('a/b/c/d'), equals('a/b/c'));
    });

    test('should return empty string for single segment', () {
      expect(PathHelper.dirname('data.json'), equals(''));
      expect(PathHelper.dirname('/data.json'), equals(''));
    });

    test('should handle empty string', () {
      expect(PathHelper.dirname(''), equals(''));
    });
  });

  group('PathHelper - isSafeRelativePath', () {
    test('should accept plain relative path', () {
      expect(PathHelper.isSafeRelativePath('ledgers/123.json'), isTrue);
    });

    test('should reject absolute path', () {
      expect(PathHelper.isSafeRelativePath('/ledgers/123.json'), isFalse);
      expect(PathHelper.isSafeRelativePath('\\ledgers\\123.json'), isFalse);
    });

    test('should reject path traversal segments', () {
      expect(PathHelper.isSafeRelativePath('../secret.json'), isFalse);
      expect(
          PathHelper.isSafeRelativePath('ledgers/../../secret.json'), isFalse);
      expect(PathHelper.isSafeRelativePath('ledgers/..\\secret.json'), isFalse);
    });

    test('should reject empty path and dot segments', () {
      expect(PathHelper.isSafeRelativePath(''), isFalse);
      expect(PathHelper.isSafeRelativePath('./ledgers/123.json'), isFalse);
    });
  });
}
