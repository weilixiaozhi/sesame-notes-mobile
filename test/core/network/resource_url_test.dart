import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/network/resource_url.dart';

/// 个人资料与成员目录采用一致的同源路径解析规则。
void main() {
  test('空资源不产生请求地址', () {
    expect(resolveResourceUrl('https://example.test/api/', null), isNull);
    expect(resolveResourceUrl('https://example.test/api/', ''), isNull);
  });
  test('绝对资源保留原有主机、查询与编码', () {
    const value = 'https://cdn.test/avatar%20a.png?v=2';
    expect(resolveResourceUrl('https://example.test/api/', value), value);
  });
  test('相对路径、根路径与协议相对地址按 URI 规则解析', () {
    expect(
      resolveResourceUrl('https://example.test/api/', 'avatar.png'),
      'https://example.test/api/avatar.png',
    );
    expect(
      resolveResourceUrl('https://example.test/api/', '/avatars/a.png'),
      'https://example.test/avatars/a.png',
    );
    expect(
      resolveResourceUrl('https://example.test/api/', '//cdn.test/a.png'),
      'https://cdn.test/a.png',
    );
  });
  test('无效基址拒绝解析相对资源，不把配置内容带入错误文案', () {
    expect(
      () => resolveResourceUrl('http://[', 'avatar.png'),
      throwsFormatException,
    );
  });
}
