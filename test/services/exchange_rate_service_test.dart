import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../helpers/test_isolation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/shared/services/exchange_rate_service.dart';

// 把解析用的 Map 包成 200 响应,等价原测试里的 ResponseBody.fromString。
http.Response _json(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetGlobalTestState());

  test('首源失败滑到次源,并记住成功源', () async {
    // 用 MockClient 桩接网络:fastly 抛异常模拟超时,其余源返回成功 JSON。
    final client = MockClient((request) {
      if (request.url.host == 'fastly.jsdelivr.net') {
        throw http.ClientException('timeout');
      }
      return Future.value(
        _json({
          'date': '2026-06-10',
          'cny': {'usd': 0.1477, 'jpy': 21.65},
        }),
      );
    });
    final svc = ExchangeRateService(client: client);
    final r = await svc.fetch('CNY');
    expect(r.source, 'gcore.jsdelivr.net');
    expect(r.rateDate, '2026-06-10');
    expect(r.ratesBaseToQuote['USD'], '0.1477'); // 键转大写,值转字符串
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('rateSourceIndex'), 1); // 下次从 gcore 起跳
  });

  test('全链失败抛 RateFetchException', () async {
    final client = MockClient((request) => throw http.ClientException('down'));
    final svc = ExchangeRateService(client: client);
    expect(() => svc.fetch('CNY'), throwsA(isA<RateFetchException>()));
  });

  test('两种公网格式仅保留可安全取倒数的正汇率，正常币种不受坏值影响', () {
    final table = {
      'badNan': double.nan,
      'badInfinity': double.infinity,
      'badNegativeInfinity': double.negativeInfinity,
      'badTiny': double.minPositive,
      'badZero': 0,
      'badNegative': -1,
      'badText': 'invalid',
      'CNY': 6.7715,
      'JPY': 146.6,
    };
    final results = [
      ExchangeRateService.parseFrankfurter({
        'base': 'USD',
        'date': '2026-06-10',
        'rates': table,
      }),
      ExchangeRateService.parseFawaz('USD', {
        'date': '2026-06-10',
        'usd': table,
      }),
    ];
    for (final result in results) {
      expect(result.ratesBaseToQuote, {'CNY': '6.7715', 'JPY': '146.6'});
      expect(result.rateDate, '2026-06-10');
    }
  });

  test('源仅有溢出汇率时切换到下一源，不把异常源记为成功', () async {
    final client = MockClient((request) async {
      if (request.url.host == 'fastly.jsdelivr.net') {
        return http.Response('{"date":"2026-06-10","cny":{"usd":1e999}}', 200);
      }
      return _json({
        'date': '2026-06-10',
        'cny': {'usd': 0.1477},
      });
    });
    addTearDown(client.close);
    final result = await ExchangeRateService(client: client).fetch('CNY');
    expect(result.source, 'gcore.jsdelivr.net');
    expect(result.ratesBaseToQuote, {'USD': '0.1477'});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('rateSourceIndex'), 1);
  });

  test('记住源后下次从它起跳(跳过更靠前的源)', () async {
    SharedPreferences.setMockInitialValues({'rateSourceIndex': 1});
    final hitHosts = <String>[];
    final client = MockClient((request) {
      hitHosts.add(request.url.host);
      return Future.value(
        _json({
          'date': '2026-06-10',
          'cny': {'usd': 0.1477},
        }),
      );
    });
    final svc = ExchangeRateService(client: client);
    final r = await svc.fetch('CNY');
    expect(hitHosts.first, 'gcore.jsdelivr.net'); // 从 idx1 起跳,fastly 被跳过
    expect(r.source, 'gcore.jsdelivr.net');
  });
}
