import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/date/date_parser.dart';

void main() {
  test('导入严格解析复用原格式，但不接受日期滚动、时间溢出或尾随内容', () {
    for (final value in [
      '2026-09-14',
      '2026/9/14',
      '2026年9月14日',
      '09/14/2026',
    ]) {
      expect(DateParser.tryParseStrict(value), DateTime(2026, 9, 14));
    }
    for (final value in [
      '2026-02-30',
      '2026年2月30日',
      '2026-09-14T24:00:00',
      '2026年9月14日多余内容',
    ]) {
      expect(DateParser.tryParseStrict(value), isNull);
    }
    expect(
      DateParser.tryParseStrict('2026-09-14T08:00:00Z')!.toUtc(),
      DateTime.utc(2026, 9, 14, 8),
    );
  });
  test('严格ISO偏移按时分解析，保持有无冒号、跨日和当地无偏移时间语义', () {
    for (final (suffix, expected) in [
      ('+08:00', DateTime.utc(2026, 9, 27, 4)),
      ('+0800', DateTime.utc(2026, 9, 27, 4)),
      ('-08:00', DateTime.utc(2026, 9, 27, 20)),
      ('-0800', DateTime.utc(2026, 9, 27, 20)),
      ('+00:00', DateTime.utc(2026, 9, 27, 12)),
      ('-0000', DateTime.utc(2026, 9, 27, 12)),
      ('+15:00', DateTime.utc(2026, 9, 26, 21)),
      ('+23:59', DateTime.utc(2026, 9, 26, 12, 1)),
      ('-2359', DateTime.utc(2026, 9, 28, 11, 59)),
    ]) {
      expect(
        DateParser.tryParseStrict('2026-09-27T12:00:00$suffix')?.toUtc(),
        expected,
        reason: suffix,
      );
    }
    final local = DateParser.tryParseStrict('2026-09-27T12:34:56');
    expect(local, DateTime(2026, 9, 27, 12, 34, 56));
    expect(local!.isUtc, isFalse);
  });

  test('严格ISO偏移拒绝小时或分钟溢出，不滚动成其他日期', () {
    for (final suffix in [
      '+24:00',
      '-24:00',
      '+00:60',
      '-0060',
      '+99:99',
      '-9999',
      '+2360',
    ]) {
      expect(
        DateParser.tryParseStrict('2026-09-27T12:00:00$suffix'),
        isNull,
        reason: suffix,
      );
    }
  });

  group('DateParser.parse — 空与兜底', () {
    final fallback = DateTime(2020, 1, 2, 3, 4, 5);

    test('null 返回 fallback', () {
      expect(DateParser.parse(null, fallback: fallback), fallback);
    });

    test('空白字符串返回 fallback', () {
      expect(DateParser.parse('   ', fallback: fallback), fallback);
    });

    test('无法识别的字符串返回 fallback', () {
      expect(DateParser.parse('not a date', fallback: fallback), fallback);
    });
  });

  group('DateParser.tryParse', () {
    test('null / 空 / 全空白 返回 null', () {
      expect(DateParser.tryParse(null), isNull);
      expect(DateParser.tryParse(''), isNull);
      expect(DateParser.tryParse('   '), isNull);
    });

    test('非空但无法解析的串:返回 null(契约:失败不回落当前时间)', () {
      // 契约锚点:tryParse 文档承诺"失败返回 null"。CSV 导入依赖该语义
      // 把坏日期行按失败跳过,若回落 now() 会把坏行静默写成今天。
      expect(DateParser.tryParse('not a date'), isNull);
    });
  });

  group('ISO 8601(本地时区)', () {
    test('纯日期', () {
      final d = DateParser.parse('2024-11-05');
      expect(d.year, 2024);
      expect(d.month, 11);
      expect(d.day, 5);
      expect(d.isUtc, isFalse);
    });

    test('带时间', () {
      final d = DateParser.parse('2024-11-05T23:16:00');
      expect(d.year, 2024);
      expect(d.month, 11);
      expect(d.day, 5);
      expect(d.hour, 23);
      expect(d.minute, 16);
      expect(d.isUtc, isFalse);
    });
  });

  group('中文日期(本地时区)', () {
    test('年月日', () {
      final d = DateParser.parse('2024年11月5日');
      expect(d, DateTime(2024, 11, 5));
    });

    test('年月日 时:分', () {
      final d = DateParser.parse('2024年11月5日 12:30');
      expect(d, DateTime(2024, 11, 5, 12, 30));
    });

    test('年月日 时:分:秒(零填充)', () {
      final d = DateParser.parse('2024年11月05日 12:30:45');
      expect(d, DateTime(2024, 11, 5, 12, 30, 45));
    });
  });

  group('常见格式(无 UTC 标记 → 本地时间)', () {
    test('yyyy/MM/dd', () {
      final d = DateParser.parse('2024/11/05');
      expect(d.year, 2024);
      expect(d.month, 11);
      expect(d.day, 5);
      expect(d.isUtc, isFalse);
    });

    test('yyyy/MM/dd HH:mm — 分量原样,本地时区不偏移', () {
      final d = DateParser.parse('2024/08/29 23:16');
      expect(d.year, 2024);
      expect(d.month, 8);
      expect(d.day, 29);
      expect(d.hour, 23);
      expect(d.minute, 16);
      expect(d.isUtc, isFalse);
    });

    test('yyyy-MM-dd HH:mm:ss', () {
      final d = DateParser.parse('2024-08-29 23:16:05');
      expect(d.year, 2024);
      expect(d.day, 29);
      expect(d.hour, 23);
      expect(d.second, 5);
      expect(d.isUtc, isFalse);
    });
  });

  group('回归:无 UTC 标记一律本地,不产生 8h 偏移(CSV 导入)', () {
    test('单数字月份 2026-6-25 00:00 → 本地,且与零填充同一时刻', () {
      final single = DateParser.parse('2026-6-25 00:00');
      final padded = DateParser.parse('2026-06-25 00:00');
      expect(single.isUtc, isFalse);
      expect(single.year, 2026);
      expect(single.month, 6);
      expect(single.day, 25);
      expect(single.hour, 0);
      // 关键:两种写法必须解析成同一时刻(8 小时时区差即回归)
      expect(single.difference(padded), Duration.zero);
    });

    test('单数字月份月末晚间不跨月 2025-9-30 23:45', () {
      final d = DateParser.parse('2025-9-30 23:45');
      expect(d.isUtc, isFalse);
      expect(d.month, 9);
      expect(d.day, 30);
      expect(d.hour, 23);
      expect(d.minute, 45);
    });

    test('斜杠格式同样本地 2024/08/29 23:16', () {
      final d = DateParser.parse('2024/08/29 23:16');
      expect(d.isUtc, isFalse);
      expect(d.hour, 23);
    });
  });
}
