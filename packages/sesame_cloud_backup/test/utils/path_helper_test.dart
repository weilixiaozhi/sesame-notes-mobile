import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:flutter_test/flutter_test.dart';

/// 备份对象路径必须保留用户目录边界，并拒绝越界访问。
void main() {
  test('对象路径规范化保留相对文件身份和空根目录', () {
    expect(PathHelper.normalize('///users//123///data.json//'),
        'users/123/data.json');
    expect(PathHelper.normalize('data.json'), 'data.json');
    expect(PathHelper.normalize(''), '');
  });

  test('拼接和父目录查询保留备份的用户目录', () {
    expect(PathHelper.join(['users', 'user123', '/ledgers/', '//456.json']),
        'users/user123/ledgers/456.json');
    expect(PathHelper.join(['users', 'user123']), 'users/user123');
    expect(PathHelper.dirname('users/user123/ledgers/456.json'),
        'users/user123/ledgers');
    expect(PathHelper.dirname('data.json'), '');
  });

  test('允许普通相对对象路径', () {
    expect(PathHelper.isSafeRelativePath('ledgers/123.json'), isTrue);
  });

  test('拒绝绝对路径', () {
    expect(PathHelper.isSafeRelativePath('/ledgers/123.json'), isFalse);
    expect(PathHelper.isSafeRelativePath('\\ledgers\\123.json'), isFalse);
  });

  test('拒绝目录穿越', () {
    expect(PathHelper.isSafeRelativePath('../secret.json'), isFalse);
    expect(PathHelper.isSafeRelativePath('ledgers/../../secret.json'), isFalse);
    expect(PathHelper.isSafeRelativePath('ledgers/..\\secret.json'), isFalse);
  });

  test('拒绝空路径和点目录', () {
    expect(PathHelper.isSafeRelativePath(''), isFalse);
    expect(PathHelper.isSafeRelativePath('./ledgers/123.json'), isFalse);
  });
}
