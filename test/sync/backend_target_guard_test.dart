import 'package:flutter_test/flutter_test.dart';
import '../../e2e/real_backend_roundtrip_test.dart'
    show validatedBackendUrl, ExistingBackendRequestPacer;

/// 验证测试目标授权与请求节流，全程使用纯函数和模拟时钟。
void main() {
  group('既有服务请求调度（纯时钟，无网络）', () {
    late int clock;
    late List<int> waits;
    late ExistingBackendRequestPacer pacer;
    setUp(() {
      clock = 0;
      waits = [];
      pacer = ExistingBackendRequestPacer(
        nowMilliseconds: () => clock,
        delay: (duration) async {
          waits.add(duration.inMilliseconds);
          clock += duration.inMilliseconds;
        },
      );
    });
    test('不同客户端共用预算，普通请求起始至少相隔250ms', () async {
      final starts = <int>[];
      for (var index = 0; index < 3; index++) {
        await pacer.waitForRequest('/api/v1/sync/push');
        starts.add(clock);
      }
      expect(starts, [0, 250, 500]);
      expect(waits, [250, 250]);
    });
    test('认证共用6500ms预算，普通请求仍按250ms开始', () async {
      final starts = <int>[];
      for (final path in [
        '/api/v1/auth/register',
        '/api/v1/sync/push',
        '/api/v1/auth/login',
        '/api/v1/sync/pull',
      ]) {
        await pacer.waitForRequest(path);
        starts.add(clock);
      }
      expect(starts, [0, 250, 6500, 6750]);
    });
    test('同帧多个客户端不能争用同一起始预算', () async {
      final starts = <int>[];
      await Future.wait(
        List.generate(3, (_) async {
          await pacer.waitForRequest('/api/v1/sync/push');
          starts.add(clock);
        }),
      );
      expect(starts, [0, 250, 500]);
    });
    test('已过预算立即开始，不把响应耗时累加为额外等待', () async {
      await pacer.waitForRequest('/api/v1/auth/register');
      clock = 10000;
      await pacer.waitForRequest('/api/v1/auth/login');
      expect(waits, isEmpty);
      await pacer.waitForRequest('/api/v1/sync/pull');
      expect(clock, 10250);
    });
  });

  const expected = 'http://192.168.50.20:8080';
  test('既有测试后端必须同时匹配精确配置和明确确认', () {
    expect(
      validatedBackendUrl(
        '$expected/',
        mode: 'existing-backend',
        confirmed: true,
        expectedBackendUrl: expected,
      ),
      expected,
    );
    expect(
      () => validatedBackendUrl(
        expected,
        mode: 'existing-backend',
        expectedBackendUrl: expected,
      ),
      throwsStateError,
    );
    expect(
      () => validatedBackendUrl(
        expected,
        mode: 'existing-backend',
        confirmed: true,
      ),
      throwsStateError,
    );
    expect(() => validatedBackendUrl(expected), throwsStateError);
    expect(
      () => validatedBackendUrl(
        expected,
        mode: 'existing-backend',
        confirmed: true,
        expectedBackendUrl: '$expected/api',
      ),
      throwsStateError,
    );
  });
  test('隔离模式只接受本机，既有模式还必须明确授权', () {
    for (final host in ['localhost', '127.0.0.1']) {
      final url = 'http://$host:8081';
      expect(validatedBackendUrl(url), url);
      expect(() => validatedBackendUrl(url, confirmed: true), throwsStateError);
      expect(
        () =>
            validatedBackendUrl(url, mode: 'existing-backend', confirmed: true),
        throwsStateError,
      );
      expect(
        validatedBackendUrl(
          url,
          mode: 'existing-backend',
          confirmed: true,
          expectedBackendUrl: url,
        ),
        url,
      );
    }
  });
  test('既有模式仅支持明确配置的 RFC1918 私有网段', () {
    for (final host in [
      '10.0.0.1',
      '172.16.0.1',
      '172.31.255.254',
      '192.168.50.20',
    ]) {
      final url = 'http://$host:8080';
      expect(
        validatedBackendUrl(
          url,
          mode: 'existing-backend',
          confirmed: true,
          expectedBackendUrl: url,
        ),
        url,
      );
    }
    for (final host in [
      '8.8.8.8',
      '172.15.0.1',
      '172.32.0.1',
      '192.169.0.1',
      'api.example.invalid',
      '10.0.0.256',
      '127.1',
      '0.0.0.0',
    ]) {
      final url = 'http://$host:8080';
      expect(
        () => validatedBackendUrl(
          url,
          mode: 'existing-backend',
          confirmed: true,
          expectedBackendUrl: url,
        ),
        throwsStateError,
      );
    }
  });
  for (final value in [
    '',
    'https://192.168.50.20:8080',
    'http://192.168.50.21:8080',
    'http://192.168.50.20:8081',
    'http://192.168.50.20',
    'http://user:secret@192.168.50.20:8080',
    'http://192.168.50.20:8080/api',
    'http://192.168.50.20:8080/?query=1',
    'http://192.168.50.20:8080/#fragment',
  ]) {
    test('拒绝非授权目标或附带信息: $value', () {
      expect(
        () => validatedBackendUrl(
          value,
          mode: 'existing-backend',
          confirmed: true,
          expectedBackendUrl: expected,
        ),
        throwsStateError,
      );
    });
  }
  test('不识别的模式不能绕过范围', () {
    expect(
      () => validatedBackendUrl('http://127.0.0.1:8081', mode: 'other'),
      throwsStateError,
    );
  });
}
