import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/features/fitness/application/fitness_library_queries.dart';

/// 官方内容异步查询在会话失效后拒绝发布原请求结果。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const empty = FitnessLibrary(
    schemaVersion: 1,
    contentVersion: 1,
    templates: [],
    plans: [],
  );
  test('刷新期间查询拥有者失效，迟到结果不能触发旧页面后续操作', () async {
    final response = Completer<FitnessLibrary>();
    var active = true;
    final queries = FitnessLibraryQueries(
      load: () async => empty,
      refresh: () => response.future,
      isCurrent: () => active,
    );
    final pending = queries.ensureOfficialContent(
      id: 'official-plan',
      plan: true,
    );
    await Future<void>.delayed(Duration.zero);
    active = false;
    response.complete(empty);
    await expectLater(pending, throwsStateError);
  });
}
