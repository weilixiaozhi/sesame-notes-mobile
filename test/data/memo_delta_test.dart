import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo_delta.dart';

void main() {
  final vectors =
      jsonDecode(
            File('test/fixtures/memo_delta_vectors.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final sample in vectors['valid'] as List) {
    test('delta_v1 与编辑器往返 ${sample['id']}', () {
      final body = sample['body'] as Map<String, dynamic>;
      final before = jsonEncode(body);
      validateMemoDelta(body);
      expect(jsonEncode(body), before);
      final document = Document.fromJson(body['ops'] as List);
      addTearDown(document.close);
      expect(document.toPlainText(), sample['text']);
      validateMemoDelta({'ops': document.toDelta().toJson()});
    });
  }
  for (final sample in vectors['invalid'] as List) {
    test('拒绝不支持的正文 ${sample['id']}', () {
      expect(
        () => validateMemoDelta(sample['body']),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            '安全错误代码',
            'INVALID_MEMO_DELTA',
          ),
        ),
      );
    });
  }
}
