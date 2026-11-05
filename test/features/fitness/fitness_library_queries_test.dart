import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/data/repositories/fitness_library_repository.dart';
import 'package:sesame_notes/features/fitness/application/fitness_library_queries.dart';
import 'package:sesame_notes/shared/providers/fitness_library_provider.dart';

/// 官方入口由应用查询统一补齐内容，展示层不再创建仓储或发起刷新。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FitnessLibrary library;
  const empty = FitnessLibrary(
    schemaVersion: 1,
    contentVersion: 1,
    templates: [],
    plans: [],
  );
  setUpAll(() async {
    library = FitnessLibrary.fromJson(
      jsonDecode(await File('assets/fitness/library.json').readAsString())
          as Map<String, dynamic>,
    );
  });

  test('缓存中已有目标时直接返回同一快照，不发刷新请求', () async {
    var refreshes = 0;
    final queries = FitnessLibraryQueries(
      load: () async => library,
      refresh: () async {
        refreshes++;
        return library;
      },
      isCurrent: () => true,
    );
    expect(
      await queries.ensureOfficialContent(
        id: library.plans.first.id,
        plan: true,
      ),
      same(library),
    );
    expect(
      await queries.ensureOfficialContent(
        id: library.templates.first.id,
        plan: false,
      ),
      same(library),
    );
    expect(refreshes, 0);
  });

  test('缺失目标由共享仓储刷新并失效快照，之后读取新内容', () async {
    final repository = _Repository();
    var refreshed = false;
    when(() => repository.refresh()).thenAnswer((_) async {
      refreshed = true;
      return true;
    });
    final container = ProviderContainer(
      overrides: [
        fitnessLibraryRepositoryProvider.overrideWith(
          (ref) async => repository,
        ),
        fitnessLibraryProvider.overrideWith(
          (ref) async => refreshed ? library : empty,
        ),
      ],
    );
    addTearDown(container.dispose);
    final result = await container
        .read(fitnessLibraryQueriesProvider)
        .ensureOfficialContent(id: library.templates.first.id, plan: false);
    expect(result, same(library));
    verify(() => repository.refresh()).called(1);
    expect(await container.read(fitnessLibraryProvider.future), same(library));
  });

  test('离线刷新没有补齐目标时保留原快照，页面可执行已有友好回退', () async {
    var refreshes = 0;
    final queries = FitnessLibraryQueries(
      load: () async => empty,
      refresh: () async {
        refreshes++;
        return empty;
      },
      isCurrent: () => true,
    );
    expect(
      await queries.ensureOfficialContent(
        id: library.plans.first.id,
        plan: true,
      ),
      same(empty),
    );
    expect(refreshes, 1);
  });

  test('刷新期间查询拥有者失效，迟到结果不能触发旧页面后续操作', () async {
    final response = Completer<FitnessLibrary>();
    var active = true;
    final queries = FitnessLibraryQueries(
      load: () async => empty,
      refresh: () => response.future,
      isCurrent: () => active,
    );
    final pending = queries.ensureOfficialContent(
      id: library.plans.first.id,
      plan: true,
    );
    await Future<void>.delayed(Duration.zero);
    active = false;
    response.complete(library);
    await expectLater(pending, throwsStateError);
  });
}

/// 只替换应用查询需要的内容刷新，禁止测试访问真实网络与偏好存储。
class _Repository extends Mock implements FitnessLibraryRepository {}
