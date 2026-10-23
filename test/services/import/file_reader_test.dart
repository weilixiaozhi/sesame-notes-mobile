import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gbk_codec/gbk_codec.dart';

import 'package:sesame_notes/features/settings/infrastructure/file_reader.dart';

import '../../helpers/test_platform_file.dart';
import '../../helpers/test_isolation.dart';

PlatformFile _bytesFile(String name, List<int> bytes) =>
    TestPlatformFile(name: name, bytes: bytes);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('decodeBytes 编码探测', () {
    test('UTF-8 无 BOM 直接解码', () {
      expect(
        FileReaderService.decodeBytes(utf8.encode('你好,world')),
        '你好,world',
      );
    });

    test('UTF-8 带 BOM 去掉 BOM 解码', () {
      final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode('hello')];
      expect(FileReaderService.decodeBytes(bytes), 'hello');
    });

    test('UTF-16 LE 带 BOM 解码', () {
      final bytes = <int>[0xFF, 0xFE];
      for (final unit in '中文测试'.codeUnits) {
        bytes.add(unit & 0xFF);
        bytes.add((unit >> 8) & 0xFF);
      }
      expect(FileReaderService.decodeBytes(bytes), '中文测试');
    });

    test('UTF-16 BE 带 BOM 解码', () {
      final bytes = <int>[0xFE, 0xFF];
      for (final unit in '中文测试'.codeUnits) {
        bytes.add((unit >> 8) & 0xFF);
        bytes.add(unit & 0xFF);
      }
      expect(FileReaderService.decodeBytes(bytes), '中文测试');
    });

    test('GBK 解码命中中文字符', () {
      final bytes = gbk_bytes.encode('支付宝账单测试');
      expect(FileReaderService.decodeBytes(bytes), '支付宝账单测试');
    });

    test('非法 UTF-8 且非 GBK 时回落 allowMalformed UTF-8', () {
      final bytes = <int>[0xC3, 0x28]; // 非法 UTF-8 序列
      final text = FileReaderService.decodeBytes(bytes);
      expect(text, isNotEmpty);
    });

    test('合法 UTF-8 三字节中文按 UTF-8 解码', () {
      // 0xE4 0xBD 0xA0 是「你」的 UTF-8 编码，应完整保留中文字符。
      expect(FileReaderService.decodeBytes(<int>[0xE4, 0xBD, 0xA0]), '你');
    });
  });

  group('readFile bytes 入参', () {
    test('空字节给出可读原因', () async {
      // 读不到内容必须报错：静默返回空串会让导入无提示地结束。
      await expectLater(
        FileReaderService.readFile(_bytesFile('empty.csv', [])),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('文件为空'),
          ),
        ),
      );
    });

    test('CSV UTF-8 内容直接解码', () async {
      final result = await FileReaderService.readFile(
        _bytesFile('a.csv', utf8.encode('金额,分类\n12.5,餐饮')),
      );
      expect(result, contains('餐饮'));
    });

    test('入口取消抛 FileReadCancelledException', () async {
      expect(
        () => FileReaderService.readFile(
          _bytesFile('a.csv', utf8.encode('x')),
          isCancelled: () => true,
        ),
        throwsA(isA<FileReadCancelledException>()),
      );
    });

    test('XLSX 调用 converter 并返回结果', () async {
      final result = await FileReaderService.readFile(
        _bytesFile('a.xlsx', [1, 2, 3]),
        xlsxConverter: (bytes) => 'converted:${bytes.length}',
      );
      expect(result, 'converted:3');
    });

    test('XLSX 缺少 converter 抛 ArgumentError', () async {
      expect(
        () => FileReaderService.readFile(_bytesFile('a.xlsx', [1, 2, 3])),
        throwsArgumentError,
      );
    });

    test('异步转换期间取消后丢弃结果', () async {
      final started = Completer<void>();
      final conversion = Completer<String>();
      var cancelled = false;
      final result = FileReaderService.readFile(
        _bytesFile('a.xlsx', [1, 2, 3]),
        isCancelled: () => cancelled,
        xlsxConverter: (bytes) {
          started.complete();
          return conversion.future;
        },
      );
      final rejected = expectLater(
        result,
        throwsA(isA<FileReadCancelledException>()),
      );
      await started.future;
      cancelled = true;
      conversion.complete('不能交付的旧结果');
      await rejected;
    });

    test('取消后迟到的转换错误按取消处理', () async {
      final started = Completer<void>();
      final conversion = Completer<String>();
      var cancelled = false;
      final result = FileReaderService.readFile(
        _bytesFile('a.xlsx', [1, 2, 3]),
        isCancelled: () => cancelled,
        xlsxConverter: (bytes) {
          started.complete();
          return conversion.future;
        },
      );
      final rejected = expectLater(
        result,
        throwsA(isA<FileReadCancelledException>()),
      );
      await started.future;
      cancelled = true;
      conversion.completeError(const FormatException('工作线程迟到的格式错误'));
      await rejected;
    });

    test('读取完成时已取消就不启动转换', () async {
      var checks = 0;
      var converted = false;
      await expectLater(
        FileReaderService.readFile(
          _bytesFile('a.xlsx', [1, 2, 3]),
          isCancelled: () => ++checks > 1,
          xlsxConverter: (bytes) {
            converted = true;
            return 'result';
          },
        ),
        throwsA(isA<FileReadCancelledException>()),
      );
      expect(converted, isFalse);
    });
  });

  group('readFile 文件路径', () {
    test('文件不存在给出可读原因', () async {
      await expectLater(
        FileReaderService.readFile(
          TestPlatformFile(
            name: 'missing.csv',
            path: 'Z:/definitely/missing.csv',
          ),
        ),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('文件为空或无法读取'),
          ),
        ),
      );
    });

    test('小文件读取并回调进度', () async {
      final dir = await createTestTempDirectory('sesame_fr_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/data.csv');
      await file.writeAsBytes(utf8.encode('列1,列2\n1,2\n3,4'));

      final progresses = <double>[];
      final result = await FileReaderService.readFile(
        TestPlatformFile(name: 'data.csv', path: file.path),
        onProgress: progresses.add,
      );

      expect(result, contains('列1'));
      expect(progresses, isNotEmpty);
      expect(progresses.last, 1.0);
    });

    test('大文件读取中取消抛 FileReadCancelledException', () async {
      final dir = await createTestTempDirectory('sesame_fr_');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/big.csv');
      // 超过一个 chunk（256KB），保证循环进入第二次读取前可取消
      final big = utf8.encode('x' * (256 * 1024 + 100));
      await file.writeAsBytes(big);

      var calls = 0;
      expect(
        () => FileReaderService.readFile(
          TestPlatformFile(name: 'big.csv', path: file.path),
          isCancelled: () => ++calls > 1,
        ),
        throwsA(isA<FileReadCancelledException>()),
      );
    });
  });
}
