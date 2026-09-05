/// ApiConfig 默认服务端地址测试。
///
/// 锚点：debug 构建默认直连本机验收后端（无需 dart-define），
/// release 构建默认线上地址；--dart-define=API_BASE_URL 注入时优先。
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';

void main() {
  test('debug 构建默认指向本机验收后端', () {
    if (!kDebugMode) return; // release 下本断言不适用
    expect(const ApiConfig().baseUrl, 'http://192.168.5.5:8080');
  });
}
