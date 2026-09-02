/// 应用更新检查服务单测（P2）。
///
/// 需求锚点：200 + 更新 tag → hasUpdate；同版本 → latest；
/// 非 200 / 网络异常 → unknown（降级不抛错）；版本比较按点号数值（1.10 > 1.9）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sesame_notes/data/models/app_update_info.dart';
import 'package:sesame_notes/shared/services/app_update_service.dart';

void main() {
  test('新版本：tag v1.0.1 > 当前 1.0.0 → hasUpdate', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"tag_name":"v1.0.1","html_url":"https://github.com/x/releases/tag/v1.0.1"}',
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final info = await AppUpdateService.check(
      client: client,
      currentVersion: '1.0.0',
    );
    expect(info.status, UpdateStatus.hasUpdate);
    expect(info.latestVersion, '1.0.1');
    expect(info.hasUpdate, isTrue);
  });

  test('同版本：tag 1.0.0 == 当前 1.0.0 → latest', () async {
    final client = MockClient(
      (_) async => http.Response('{"tag_name":"1.0.0"}', 200),
    );
    final info = await AppUpdateService.check(
      client: client,
      currentVersion: '1.0.0',
    );
    expect(info.status, UpdateStatus.latest);
    expect(info.hasUpdate, isFalse);
  });

  test('语义化版本：1.10 严格大于 1.9（补零对齐，不做字符串比较）', () async {
    final client = MockClient(
      (_) async => http.Response('{"tag_name":"v1.10.0"}', 200),
    );
    final info = await AppUpdateService.check(
      client: client,
      currentVersion: '1.9.0',
    );
    expect(info.status, UpdateStatus.hasUpdate);
  });

  test('非 200（私有仓库/限流）→ unknown 且不抛错', () async {
    final client = MockClient((_) async => http.Response('Forbidden', 403));
    final info = await AppUpdateService.check(
      client: client,
      currentVersion: '1.0.0',
    );
    expect(info.status, UpdateStatus.unknown);
    expect(
      info.releaseUrl,
      AppUpdateInfo.releasePageBase,
      reason: '发布页兜底必须始终可用',
    );
  });

  test('网络异常 → unknown 且不抛错', () async {
    final client = MockClient((_) async => throw http.ClientException('boom'));
    final info = await AppUpdateService.check(
      client: client,
      currentVersion: '1.0.0',
    );
    expect(info.status, UpdateStatus.unknown);
  });
}
