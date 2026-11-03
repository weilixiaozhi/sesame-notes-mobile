import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' show SesameApiClient;
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/statistics/application/cloud_record_history_provider.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_history_section.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/l10n/app_localizations_zh.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

const _query = (ledgerId: 'ledger', recordId: 'record');
final _account = NotifierProvider<SimpleStateNotifier<String?>, String?>(
  () => SimpleStateNotifier((ref) => 'account'),
);
final _generation = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 1),
);
final _context =
    NotifierProvider<
      SimpleStateNotifier<RecordHistoryContext>,
      RecordHistoryContext
    >(
      () => SimpleStateNotifier(
        (ref) => const RecordHistoryContext(
          isCloud: true,
          syncId: 'binding',
          revision: 10,
        ),
      ),
    );

/// 用可控请求和身份替代网络，仍运行正式分页状态机与迟到结果守卫。
ProviderContainer _container(CloudRecordHistoryLoader loader) =>
    ProviderContainer.test(
      overrides: [
        currentAccountIdProvider.overrideWith((ref) => ref.watch(_account)),
        authIdentityGenerationProvider.overrideWith(
          (ref) => ref.watch(_generation),
        ),
        recordHistoryContextProvider(
          _query,
        ).overrideWith((ref) async => ref.watch(_context)),
        cloudRecordHistoryLoaderProvider.overrideWithValue(loader),
      ],
    );

/// 保留超出浮点精度范围的金额文本，模拟已确认的服务端历史。
CloudRecordHistoryEntry _entry(int version, {String? id}) =>
    CloudRecordHistoryEntry(
      id: id ?? 'history-$version',
      version: version,
      createdAt: DateTime.utc(2026, 11, 3),
      operatorMemberId: 'member',
      operatorDisplayName: '服务端成员',
      changes: const {
        'amount': '12345678901234567890.1234567890',
        'note': '云端备注',
      },
    );

/// 挂载正式统一列表，来源仍使用实际分页控制器，只有网络和本机读取可控。
Future<void> _pumpHistorySection(
  WidgetTester tester,
  ProviderContainer container,
  Future<List<RecordEditHistoryDisplay>> Function() local,
) async {
  try {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ProviderScope(
          overrides: [
            recordEditHistoryProvider('record').overrideWith((ref) => local()),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransactionHistorySection(
                  ledgerId: 'ledger',
                  recordId: 'record',
                  isCloud: true,
                  displayNameOf: (_) => '本机成员',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    rethrow;
  }
}

/// 创建带指定记录时间的已确认编辑，便于独立验证统一排序。
CloudRecordHistoryEntry _timedEntry(
  int version,
  int hour,
  String text, {
  int minute = 0,
}) => CloudRecordHistoryEntry(
  id: 'cloud-$version',
  version: version,
  createdAt: DateTime.utc(2026, 11, 3, hour, minute),
  operatorDisplayName: '服务端成员',
  changes: {'note': text},
);

/// 返回固定 JSON，验证真实生成客户端的路径、分页和任意 JSON 反序列化。
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.body);
  final Map<String, Object?> body;
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 仅提供上下文核验实际使用的交易字段，其余能力不参与该只读流程。
class _Transaction extends Fake implements TransactionSnapshot {
  _Transaction(this.ledgerId);
  @override
  final String ledgerId;
  @override
  int? get serverRevision => 3;
}

/// 当前可见账本已由账本提供器校验，历史上下文仍独立核对交易归属。
class _Ledger extends Fake implements Ledger {
  @override
  String get storageMode => 'cloud';
  @override
  String? get syncId => 'binding';
}

/// 固定交易快照，避免把云请求测试和数据库建库过程耦合。
class _Transactions extends Fake implements TransactionRepository {
  _Transactions(this.value);
  final TransactionSnapshot value;
  @override
  Future<TransactionSnapshot?> getTransactionById(String id) async => value;
}

/// 真实分页、身份隔离及界面错误语义共同覆盖，不能只比较模型字段。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final visible in [true, false]) {
    test('归属核验拒绝${visible ? '跨账本交易' : '不可见账本'}', () async {
      final container = ProviderContainer.test(
        overrides: [
          currentAccountIdProvider.overrideWithValue('account'),
          authIdentityGenerationProvider.overrideWithValue(1),
          ledgerByIdProvider(
            'ledger',
          ).overrideWith((ref) async => visible ? _Ledger() : null),
          transactionDataAccessProvider.overrideWithValue(
            _Transactions(_Transaction(visible ? 'other-ledger' : 'ledger')),
          ),
        ],
      );
      final subscription = container.listen(
        recordHistoryContextProvider(_query),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await expectLater(
        container.read(recordHistoryContextProvider(_query).future),
        throwsStateError,
      );
    });
  }

  for (final context in [
    const RecordHistoryContext(isCloud: false),
    const RecordHistoryContext(isCloud: true, syncId: 'binding'),
    const RecordHistoryContext(isCloud: true, revision: 2),
  ]) {
    test('本地或未上传状态不访问云历史 ${context.syncId}/${context.revision}', () async {
      var calls = 0;
      final container = _container((query, cursor, token) async {
        calls++;
        throw StateError('不应发请求');
      });
      container.read(_context.notifier).set(context);
      final sub = container.listen(
        cloudRecordHistoryProvider(_query),
        (_, _) {},
      );
      addTearDown(sub.close);
      final state = await container.read(
        cloudRecordHistoryProvider(_query).future,
      );
      expect(calls, 0);
      expect(state.context, same(context));
    });
  }

  test('按云端版本分页，保留金额字符串，重复点击不会重复请求', () async {
    final pending = Completer<CloudRecordHistoryPage>();
    final cursors = <String?>[];
    final container = _container((query, cursor, token) async {
      cursors.add(cursor);
      return cursor == null
          ? CloudRecordHistoryPage([_entry(10)], 'page-2')
          : pending.future;
    });
    final provider = cloudRecordHistoryProvider(_query);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await container.read(provider.future);
    final controller = container.read(provider.notifier);
    final task = controller.loadMore();
    await controller.loadMore();
    expect(cursors, [null, 'page-2']);
    pending.complete(CloudRecordHistoryPage([_entry(8)], null));
    await task;
    final state = container.read(provider).requireValue;
    expect(state.items.map((item) => item.version), [10, 8]);
    expect(
      (state.items.first.changes as Map)['amount'],
      '12345678901234567890.1234567890',
    );
    expect(state.nextCursor, isNull);
  });

  test('下一页失败保留旧页及位置，重试可完成', () async {
    var fail = true;
    final container = _container((query, cursor, token) async {
      if (cursor == null) return CloudRecordHistoryPage([_entry(10)], 'next');
      if (fail) throw StateError('网络中断');
      return CloudRecordHistoryPage([_entry(9)], null);
    });
    final provider = cloudRecordHistoryProvider(_query);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.pageFailed, isTrue);
    expect(container.read(provider).requireValue.items.single.version, 10);
    expect(container.read(provider).requireValue.nextCursor, 'next');
    fail = false;
    await container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.pageFailed, isFalse);
    expect(container.read(provider).requireValue.items.length, 2);
  });

  for (final identity in ['account', 'generation', 'binding']) {
    test('$identity变化后迟到的下一页不能进入新历史', () async {
      final pending = Completer<CloudRecordHistoryPage>();
      var firstCalls = 0;
      final tokens = <CancelToken>[];
      final container = _container((query, cursor, token) async {
        tokens.add(token);
        if (cursor == null) {
          firstCalls++;
          return CloudRecordHistoryPage([
            _entry(firstCalls == 1 ? 10 : 20),
          ], firstCalls == 1 ? 'next' : null);
        }
        return pending.future;
      });
      final provider = cloudRecordHistoryProvider(_query);
      final sub = container.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await container.read(provider.future);
      final task = container.read(provider.notifier).loadMore();
      if (identity == 'account') container.read(_account.notifier).set('other');
      if (identity == 'generation') container.read(_generation.notifier).set(2);
      if (identity == 'binding') {
        container
            .read(_context.notifier)
            .set(
              const RecordHistoryContext(
                isCloud: true,
                syncId: 'new-binding',
                revision: 20,
              ),
            );
      }
      await container.pump();
      await container.read(provider.future);
      pending.complete(CloudRecordHistoryPage([_entry(9)], null));
      await task;
      expect(container.read(provider).requireValue.items.single.version, 20);
      expect(tokens.first.isCancelled, isTrue);
    });
  }

  test('首屏错误保持错误状态，刷新可重新获得数据', () async {
    var fail = true;
    final container = _container((query, cursor, token) async {
      if (fail) throw StateError('禁止访问');
      return CloudRecordHistoryPage([_entry(2)], null);
    });
    final provider = cloudRecordHistoryProvider(_query);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await expectLater(container.read(provider.future), throwsStateError);
    expect(container.read(provider).hasError, isTrue);
    fail = false;
    container.invalidate(provider);
    expect((await container.read(provider.future)).items.single.version, 2);
  });

  test('错序或重复页面不伪装成已完整读取', () async {
    final container = _container(
      (query, cursor, token) async => cursor == null
          ? CloudRecordHistoryPage([_entry(2)], 'next')
          : CloudRecordHistoryPage([_entry(2)], null),
    );
    final provider = cloudRecordHistoryProvider(_query);
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await container.read(provider.future);
    await container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.items.length, 1);
    expect(container.read(provider).requireValue.pageFailed, isTrue);
  });

  test('生成客户端保持归属、分页位置和任意JSON金额文本', () async {
    final body = <String, Object?>{
      'items': [
        <String, Object?>{
          'id': 'history',
          'transaction_id': 'record',
          'ledger_id': 'ledger',
          'version': 3,
          'operator_member_id': 'member',
          'operator_display_name': '云端名称',
          'created_at': '2026-11-03T00:00:00.000Z',
          'changes': {'amount': '12345678901234567890.1234567890'},
        },
      ],
      'next_cursor': 'opaque-next',
    };
    final adapter = _JsonAdapter(body);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final client = SesameApiClient(dio: dio, serializers: apiSerializers);
    final container = ProviderContainer.test(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    final page = await container.read(cloudRecordHistoryLoaderProvider)(
      _query,
      'opaque-start',
      CancelToken(),
    );
    expect(
      adapter.request!.path,
      '/api/v1/ledgers/ledger/transactions/record/history',
    );
    expect(adapter.request!.queryParameters['cursor'], 'opaque-start');
    expect(adapter.request!.queryParameters['limit'], 50);
    expect(page.items.single.operatorDisplayName, '云端名称');
    expect(page.items.single.createdAt, DateTime.utc(2026, 11, 3));
    expect(
      (page.items.single.changes as Map)['amount'],
      '12345678901234567890.1234567890',
    );
    (body['items'] as List).single['ledger_id'] = 'other-ledger';
    await expectLater(
      container.read(cloudRecordHistoryLoaderProvider)(
        _query,
        null,
        CancelToken(),
      ),
      throwsFormatException,
    );
    final row = (body['items'] as List).single as Map<String, Object?>;
    row['ledger_id'] = 'ledger';
    row['operator_member_id'] = null;
    row['operator_display_name'] = null;
    row['changes'] = [
      'unrecognized-shape',
      {'precise': '9007199254740993.1234567890'},
    ];
    final unknown = await container.read(cloudRecordHistoryLoaderProvider)(
      _query,
      null,
      CancelToken(),
    );
    expect(unknown.items.single.operatorMemberId, isNull);
    expect(unknown.items.single.operatorDisplayName, isNull);
    expect(unknown.items.single.changes, row['changes']);
    dio.close(force: true);
  });

  test('摘要显示存储内容不伪造前后差异且保留金额精度', () {
    final l10n = AppLocalizationsZh();
    final summary = describeCloudHistoryChanges({
      'amount': '12345678901234567890.1234567890',
      'note': '保存的备注',
      'base_revision': 7,
    }, l10n);
    expect(summary, contains('12345678901234567890.1234567890'));
    expect(summary, contains('保存的备注'));
    expect(summary, isNot(contains('base_revision')));
    expect(
      describeCloudHistoryChanges({'unknown_field': 4}, l10n),
      l10n.recordHistoryUpdated,
    );
    expect(
      describeCloudHistoryChanges({'action': 'delete'}, l10n),
      l10n.recordHistoryDeleted,
    );
  });

  testWidgets('一侧读取失败保留可用记录并保持原有重试操作', (tester) async {
    final container = _container(
      (query, cursor, token) async => throw StateError('网络断开'),
    );
    final local = RecordEditHistoryDisplay(
      version: 9,
      summary: '本机备注',
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ProviderScope(
          overrides: [
            recordEditHistoryProvider(
              'record',
            ).overrideWith((ref) async => [local]),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: TransactionHistorySection(
                  ledgerId: 'ledger',
                  recordId: 'record',
                  isCloud: true,
                  displayNameOf: (_) => '本机成员',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('本机备注'), findsOneWidget);
    expect(find.text('暂时无法读取历史，请重试。'), findsOneWidget);
    expect(find.text('暂无编辑历史'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('统一列表时间倒序，分页失败保留记录，重试后重新排序', (tester) async {
    final cursors = <String?>[];
    var failPage = true;
    var localReads = 0;
    final container = _container((query, cursor, token) async {
      cursors.add(cursor);
      if (cursor == null) {
        return CloudRecordHistoryPage([
          _timedEntry(5, 12, '中午编辑'),
          _timedEntry(4, 11, '上午编辑'),
        ], 'page-2');
      }
      if (failPage) throw StateError('分页暂不可用');
      return CloudRecordHistoryPage([
        _timedEntry(3, 10, '较早编辑', minute: 30),
      ], null);
    });
    await _pumpHistorySection(tester, container, () async {
      localReads++;
      return [
        RecordEditHistoryDisplay(
          version: 2,
          summary: '较新的记录',
          createdAt: DateTime.utc(2026, 11, 3, 12, 30),
        ),
        RecordEditHistoryDisplay(
          version: 5,
          summary: '最早的记录',
          createdAt: DateTime.utc(2026, 11, 3, 10),
        ),
        RecordEditHistoryDisplay(
          version: 3,
          summary: '中间的记录',
          createdAt: DateTime.utc(2026, 11, 3, 11, 30),
        ),
      ];
    });
    for (final removed in ['云端历史', '本机历史', '仅供查看']) {
      expect(find.text(removed), findsNothing);
    }
    expect(
      tester.getTopLeft(find.text('较新的记录')).dy,
      lessThan(tester.getTopLeft(find.text('备注: 中午编辑')).dy),
    );
    expect(
      tester.getTopLeft(find.text('备注: 中午编辑')).dy,
      lessThan(tester.getTopLeft(find.text('中间的记录')).dy),
    );
    expect(
      tester.getTopLeft(find.text('中间的记录')).dy,
      lessThan(tester.getTopLeft(find.text('备注: 上午编辑')).dy),
    );
    await tester.ensureVisible(find.text('加载更多'));
    await tester.tap(find.text('加载更多'));
    await tester.pumpAndSettle();
    expect(find.text('最早的记录'), findsOneWidget);
    expect(find.text('备注: 中午编辑'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.text('暂无编辑历史'), findsNothing);
    failPage = false;
    await tester.ensureVisible(find.text('重试'));
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('备注: 较早编辑')).dy,
      lessThan(tester.getTopLeft(find.text('最早的记录')).dy),
    );
    expect(find.text('重试'), findsNothing);
    expect(cursors, [null, 'page-2', 'page-2']);
    expect(localReads, 1);
    expect(find.byTooltip('刷新'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('相同时间版本和文本的记录不猜测去重，相同时刻保持稳定顺序', (tester) async {
    final container = _container(
      (query, cursor, token) async =>
          CloudRecordHistoryPage([_timedEntry(5, 12, '相同文字')], null),
    );
    await _pumpHistorySection(
      tester,
      container,
      () async => [
        RecordEditHistoryDisplay(
          version: 5,
          summary: '备注: 相同文字',
          createdAt: DateTime.utc(2026, 11, 3, 12),
        ),
        RecordEditHistoryDisplay(
          version: 5,
          summary: '同刻记录甲',
          createdAt: DateTime.utc(2026, 11, 3, 12),
        ),
        RecordEditHistoryDisplay(
          version: 5,
          summary: '同刻记录乙',
          createdAt: DateTime.utc(2026, 11, 3, 12),
        ),
      ],
    );
    expect(find.text('备注: 相同文字'), findsNWidgets(2));
    expect(find.text('v5'), findsNWidgets(4));
    final duplicatePositions = tester
        .getTopLeft(find.text('备注: 相同文字').at(0))
        .dy;
    expect(
      duplicatePositions,
      lessThan(tester.getTopLeft(find.text('备注: 相同文字').at(1)).dy),
    );
    expect(
      tester.getTopLeft(find.text('同刻记录甲')).dy,
      lessThan(tester.getTopLeft(find.text('同刻记录乙')).dy),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('同刻记录甲')).dy,
      lessThan(tester.getTopLeft(find.text('同刻记录乙')).dy),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('本机读取失败仍展示已读历史，重试不重复请求成功来源', (tester) async {
    var localFailed = true;
    var requests = 0;
    final container = _container((query, cursor, token) async {
      requests++;
      return CloudRecordHistoryPage([_timedEntry(5, 12, '已读记录')], null);
    });
    await _pumpHistorySection(tester, container, () async {
      if (localFailed) throw StateError('读取暂不可用');
      return [
        RecordEditHistoryDisplay(
          version: 2,
          summary: '恢复的记录',
          createdAt: DateTime.utc(2026, 11, 3, 13),
        ),
      ];
    });
    expect(find.text('备注: 已读记录'), findsOneWidget);
    expect(find.text('暂无编辑历史'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    localFailed = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('恢复的记录'), findsOneWidget);
    expect(find.text('重试'), findsNothing);
    expect(requests, 1);
    expect(
      tester.getTopLeft(find.text('恢复的记录')).dy,
      lessThan(tester.getTopLeft(find.text('备注: 已读记录')).dy),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
