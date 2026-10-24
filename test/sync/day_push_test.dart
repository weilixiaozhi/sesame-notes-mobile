import 'dart:convert';
import 'package:sesame_notes/data/models/sync_issue.dart';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/data/models/day_event.dart' as days;
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/day_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import '../helpers/test_isolation.dart';

class _Api extends Mock implements SyncApi {}

const _bookId = '11111111-1111-4111-8111-111111111111';
const _eventId = '22222222-2222-4222-8222-222222222222';
const _syncId = '33333333-3333-4333-8333-333333333333';
const _accountId = '44444444-4444-4444-8444-444444444444';

/// 构造业务生日定义，测试期望独立于同步请求序列化实现。
days.DayEvent _event(String name) => days.DayEvent(
  id: _eventId,
  dayBookId: _bookId,
  definition: days.DayEventDefinition(
    name: name,
    category: 'birthday',
    repeatType: 'yearly',
    statisticType: 'year',
    event: days.OriginalDate.solar(days.DateOnly(2000, 1, 1)),
  ),
  createdAt: DateTime.utc(2026, 9, 7),
  updatedAt: DateTime.utc(2026, 9, 7),
);

/// 验证日子变更上传、拒收重试及云本转本地的完整数据保留。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late DayRepository repository;
  late _Api api;
  late SesameApiClient client;
  late SyncService service;
  late List<List<Map<String, dynamic>>> sent;
  late Map<String, int> revisions;
  late String? currentAccount;
  late Map<String, PostSyncPush200ResponseOutcomesInnerStatusEnum> statuses;
  Future<void> Function(Map<String, dynamic>)? beforeResponse;
  PostSyncPush200ResponseOutcomesInner Function(
    PostSyncPush200ResponseOutcomesInner,
  )?
  rewriteOutcome;
  late bool extraRemoteEvent;

  setUpAll(
    () => registerFallbackValue(
      PostSyncPushRequest(
        (b) => b
          ..deviceId = 'device'
          ..changes = ListBuilder(),
      ),
    ),
  );
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    currentAccount = _accountId;
    repository = DayRepository(
      db,
      validateAndProject: DayDateRules().validateAndProject,
      accountIdGetter: () => currentAccount,
      changeRecorder: ChangeRecorderImpl(
        db,
        accountIdGetter: () => currentAccount,
      ),
    );
    api = _Api();
    client = SesameApiClient();
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      apiOverride: api,
      dayRepository: repository,
      currentAccountIdGetter: () => currentAccount,
    );
    sent = [];
    revisions = {};
    statuses = {};
    beforeResponse = null;
    rewriteOutcome = null;
    extraRemoteEvent = false;
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      final wire =
          client.serializers.serializeWith(
                PostSyncPushRequest.serializer,
                request,
              )
              as Map<String, dynamic>;
      final changes = (wire['changes'] as List).cast<Map<String, dynamic>>();
      sent.add(changes);
      final outcomes = <PostSyncPush200ResponseOutcomesInner>[];
      for (final change in changes) {
        final row =
            await (db.select(db.syncChanges)..where(
                  (c) => c.mutationId.equals(change['mutation_id'] as String),
                ))
                .getSingle();
        expect(row.frozenRequest, isNotNull, reason: 'HTTP 首次发送前必须已持久化完整冻结请求');
        await beforeResponse?.call(change);
        final id = change['entity_id'] as String;
        final revision = (revisions[id] ?? 0) + 1;
        revisions[id] = revision;
        outcomes.add(
          PostSyncPush200ResponseOutcomesInner(
            (b) => b
              ..mutationId = change['mutation_id'] as String
              ..entityId = id
              ..status =
                  statuses[id] ??
                  PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
              ..changeId = '$revision'
              ..revision = revision
              ..syncId = _syncId
              ..currentRevision = 4
              ..currentDeleted = false
              ..currentEntity = JsonObject({
                ...change['payload'] as Map<String, dynamic>,
                'id': id,
                'day_book_id': _bookId,
                'sync_id': _syncId,
                'name': '远端',
                'revision': 4,
                'created_at': '2026-09-07T00:00:00.000Z',
                'updated_at': '2026-09-07T00:00:00.000Z',
                'deleted_at': null,
              }),
          ),
        );
      }
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = ListBuilder(
              outcomes.map(
                (outcome) => rewriteOutcome?.call(outcome) ?? outcome,
              ),
            )
            ..serverCursor = '99',
        ),
      );
    });
    when(
      () => api.getSyncDayBooksFull(
        dayBookId: any(named: 'dayBookId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer((_) async {
      final book = await (db.select(
        db.dayBooks,
      )..where((b) => b.id.equals(_bookId))).getSingle();
      final events = await (db.select(
        db.dayEvents,
      )..where((e) => e.dayBookId.equals(_bookId))).get();
      final snapshot = client.serializers.deserializeWith(
        GetSyncDayBooksFull200Response.serializer,
        {
          'day_book': {
            'id': _bookId,
            'name': book.name,
            'revision': book.serverRevision,
            'sync_id': _syncId,
            'created_at': book.createdAt.toUtc().toIso8601String(),
            'updated_at': book.updatedAt.toUtc().toIso8601String(),
            'deleted_at': null,
          },
          'day_events': [
            for (final row in events)
              {
                ...dayEventPayload(dayEventFromRow(row)),
                'id': row.id,
                'day_book_id': _bookId,
                'sync_id': _syncId,
                'revision': row.serverRevision,
                'updated_at': row.updatedAt.toUtc().toIso8601String(),
                'deleted_at': null,
              },
            if (extraRemoteEvent &&
                !events.any(
                  (e) => e.id == '66666666-6666-4666-8666-666666666666',
                ))
              {
                ...dayEventPayload(_event('另一设备新增')),
                'id': '66666666-6666-4666-8666-666666666666',
                'day_book_id': _bookId,
                'sync_id': _syncId,
                'revision': 1,
                'updated_at': '2026-09-07T00:00:00.000Z',
                'deleted_at': null,
              },
          ],
          'server_cursor': extraRemoteEvent ? '43' : '42',
        },
      );
      return Response(
        requestOptions: RequestOptions(path: '/sync/day-books/full'),
        data: snapshot,
      );
    });
    await repository.createBook(
      id: _bookId,
      name: '日子本',
      storageMode: 'cloud',
      accountId: _accountId,
    );
  });
  tearDown(() async => db.close());

  test('父本拒绝暂停子记录，其他本仍可独立确认', () async {
    await repository.saveEvent(_event('等待'), accountId: _accountId);
    const secondId = '55555555-5555-4555-8555-555555555555';
    await repository.createBook(
      id: secondId,
      name: '其他本',
      storageMode: 'cloud',
      accountId: _accountId,
    );
    statuses[_bookId] = PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid;
    await service.push();
    expect(
      sent.expand((request) => request).map((change) => change['entity_id']),
      [_bookId, secondId],
    );
    final parent = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(_bookId))).getSingle();
    expect(parent.rejectionReason, isNotNull);
    await service.push();
    expect(sent.length, 2);
  });

  test('记录冲突保留最终本地分支，采用远端原子清理该账号该实体链', () async {
    await repository.saveEvent(_event('初稿'), accountId: _accountId);
    await service.push();
    await repository.saveEvent(_event('中间'), accountId: _accountId);
    await repository.saveEvent(_event('最终'), accountId: _accountId);
    statuses[_eventId] =
        PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
    await service.push();
    final conflict = await db.select(db.syncConflicts).getSingle();
    expect(conflict.accountId, _accountId);
    expect(conflict.dayBookId, _bookId);
    expect(jsonDecode(conflict.localPayload)['name'], '最终');
    expect((await db.select(db.dayEvents).getSingle()).name, '最终');
    await service.resolveConflictAdoptRemote(conflict.id);
    expect((await db.select(db.dayEvents).getSingle()).name, '远端');
    expect((await db.select(db.dayEvents).getSingle()).serverRevision, 4);
    expect(
      await (db.select(db.syncChanges)..where(
            (c) => d.Expression.and([
              c.entityId.equals(_eventId),
              c.pushedAt.isNull(),
            ]),
          ))
          .get(),
      isEmpty,
    );
  });

  test('OPEN后继续编辑再保留本地，发送决策时的最终队尾定义', () async {
    await repository.saveEvent(_event('初始'), accountId: _accountId);
    await service.push();
    await repository.saveEvent(_event('产生冲突的旧分支'), accountId: _accountId);
    statuses[_eventId] =
        PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
    await service.push();
    final conflict = await db.select(db.syncConflicts).getSingle();
    await repository.saveEvent(_event('冲突后最终编辑'), accountId: _accountId);
    await service.resolveConflictKeepLocal(conflict.id);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).getSingle();
    expect(jsonDecode(pending.payload)['name'], '冲突后最终编辑');
    expect(pending.baseRevision, 4);
    statuses.remove(_eventId);
    await service.push();
    expect(sent.last.single['payload']['name'], '冲突后最终编辑');
    expect((await db.select(db.dayEvents).getSingle()).name, '冲突后最终编辑');
  });

  for (final invalid in ['缺少版本', '缺少删除状态', '缺少快照', '零版本存活', '快照版本不一致']) {
    test('日子冲突$invalid明确失败，保留冻结请求和本地事实', () async {
      await repository.saveEvent(_event('原始'), accountId: _accountId);
      await service.push();
      await repository.saveEvent(_event('本地修改'), accountId: _accountId);
      statuses[_eventId] =
          PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
      rewriteOutcome = (outcome) => outcome.rebuild((builder) {
        switch (invalid) {
          case '缺少版本':
            builder.currentRevision = null;
          case '缺少删除状态':
            builder.currentDeleted = null;
          case '缺少快照':
            builder.currentEntity = null;
          case '零版本存活':
            builder.currentRevision = 0;
            builder.currentEntity = null;
          case '快照版本不一致':
            builder.currentRevision = 5;
        }
      });

      await expectLater(
        service.push(),
        throwsA(
          isA<FormatException>()
              .having(
                (error) => error.message,
                '实体定位',
                contains('entity=$_eventId'),
              )
              .having((error) => error.message, '请求定位', contains('mutation=')),
        ),
      );

      expect(await db.select(db.syncConflicts).get(), isEmpty);
      final pending = await (db.select(
        db.syncChanges,
      )..where((change) => change.pushedAt.isNull())).getSingle();
      expect(pending.frozenRequest, isNotNull);
      expect(pending.rejectionReason, isNull);
      expect(jsonDecode(pending.payload)['name'], '本地修改');
      final local = await db.select(db.dayEvents).getSingle();
      expect(local.name, '本地修改');
      expect(local.serverRevision, 1);
      expect(local.deletedAt, isNull);
    });
  }

  for (final keepLocal in [false, true]) {
    test('云端明确不存在的日子记录${keepLocal ? '保留本地副本' : '采用远端落墓碑'}', () async {
      await repository.saveEvent(_event('原始'), accountId: _accountId);
      await service.push();
      await repository.saveEvent(_event('需要保留的定义'), accountId: _accountId);
      statuses[_eventId] =
          PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
      rewriteOutcome = (outcome) => outcome.rebuild(
        (builder) => builder
          ..currentRevision = 0
          ..currentDeleted = true
          ..currentEntity = null,
      );
      await service.push();
      final conflict = await db.select(db.syncConflicts).getSingle();
      expect(conflict.remoteRevision, 0);
      expect(jsonDecode(conflict.remotePayload), {
        'revision': 0,
        'deleted': true,
      });

      if (keepLocal) {
        await service.resolveConflictKeepLocal(conflict.id);
      } else {
        await service.resolveConflictAdoptRemote(conflict.id);
      }

      final original = await (db.select(
        db.dayEvents,
      )..where((event) => event.id.equals(_eventId))).getSingle();
      expect(original.deletedAt, isNotNull);
      expect(original.serverRevision, 0);
      expect(original.name, '需要保留的定义');
      final active = await (db.select(
        db.dayEvents,
      )..where((event) => event.deletedAt.isNull())).get();
      expect(active.length, keepLocal ? 1 : 0);
      final pending = await (db.select(
        db.syncChanges,
      )..where((change) => change.pushedAt.isNull())).get();
      expect(pending, isEmpty);
      if (keepLocal) {
        expect(active.single.id, isNot(_eventId));
        expect(active.single.name, '需要保留的定义');
        final preservedBook =
            await (db.select(db.dayBooks)
                  ..where((book) => book.id.equals(active.single.dayBookId)))
                .getSingle();
        expect(preservedBook.storageMode, 'local');
      }
      expect(
        (await db.select(db.syncConflicts).getSingle()).status,
        keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE',
      );
    });
  }

  test('云转本机在删除未知结果时保留隐藏副本，重试同一请求后只发布一份', () async {
    await repository.saveEvent(_event('保留内容'), accountId: _accountId);
    await service.push();
    Map<String, dynamic>? frozenDelete;
    beforeResponse = (change) async {
      if (change['action'] != 'delete') return;
      final copies = await (db.select(
        db.dayBooks,
      )..where((b) => b.storageMode.equals('local'))).get();
      expect(copies.length, 1);
      expect(copies.single.isHidden, isTrue);
      expect(change['payload'], {'expected_full_cursor': '42'});
      if (frozenDelete == null) {
        frozenDelete = change;
        throw DioException(
          requestOptions: RequestOptions(path: '/sync/push'),
          type: DioExceptionType.connectionTimeout,
        );
      }
      expect(change, frozenDelete);
    };
    await expectLater(
      service.moveDayBookToLocal(dayBookId: _bookId),
      throwsA(isA<DioException>()),
    );
    final hidden = await (db.select(
      db.dayBooks,
    )..where((b) => b.storageMode.equals('local'))).getSingle();
    expect(hidden.isHidden, isTrue);
    final restored = await service.moveDayBookToLocal(dayBookId: _bookId);
    expect(restored.id, hidden.id);
    expect(restored.isHidden, isFalse);
    final copiedEvents = await (db.select(
      db.dayEvents,
    )..where((e) => e.dayBookId.equals(restored.id))).get();
    expect(copiedEvents.single.name, '保留内容');
    expect(copiedEvents.single.id, isNot(_eventId));
    expect(copiedEvents.single.serverRevision, isNull);
    expect(
      (await (db.select(
        db.dayBooks,
      )..where((b) => b.id.equals(_bookId))).getSingle()).deletedAt,
      isNotNull,
    );
  });

  test('转换快照过期重试补入另一设备新增记录，沿用同一隐藏副本身份', () async {
    await repository.saveEvent(_event('本地缓存'), accountId: _accountId);
    await service.push();
    statuses[_bookId] = PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid;
    await expectLater(
      service.moveDayBookToLocal(dayBookId: _bookId),
      throwsStateError,
    );
    final hidden = await (db.select(
      db.dayBooks,
    )..where((b) => b.storageMode.equals('local'))).getSingle();
    expect(hidden.isHidden, isTrue);
    extraRemoteEvent = true;
    statuses.remove(_bookId);
    final preview = await service.prepareScopeDelete(
      const SyncTarget('day_book', _bookId),
    );
    expect(preview.count, 2);
    await service.confirmScopeDelete(preview);
    final events = await (db.select(
      db.dayEvents,
    )..where((e) => e.dayBookId.equals(hidden.id))).get();
    expect(events.map((row) => row.name).toSet(), {'本地缓存', '另一设备新增'});
    expect(sent.last.single['payload'], {'expected_full_cursor': '43'});
  });

  test('转换被拒绝后协调器可重试，完整下载并发布原隐藏副本', () async {
    final container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'http://test.local'),
        ),
        databaseProvider.overrideWithValue(db),
        dayRepositoryProvider.overrideWithValue(repository),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
        syncServiceProvider.overrideWithValue(service),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'test',
            userId: _accountId,
            deviceId: 'device',
          ),
        );
    await repository.saveEvent(_event('原记录'), accountId: _accountId);
    await service.push();
    statuses[_bookId] = PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid;
    await expectLater(
      service.moveDayBookToLocal(dayBookId: _bookId),
      throwsStateError,
    );
    final hiddenId = (await (db.select(
      db.dayBooks,
    )..where((b) => b.isHidden.equals(true))).getSingle()).id;
    expect(await repository.getBook(_bookId, accountId: _accountId), isNull);
    await container.read(daySyncStatusProvider.future);
    extraRemoteEvent = true;
    statuses.remove(_bookId);

    // 同一转换通过协调器重试，发布副本后刷新本列表与当前选中本。
    await expectLater(
      service.moveDayBookToLocal(dayBookId: _bookId),
      throwsStateError,
    );
    final coordinator = container.read(syncCoordinatorProvider);
    final preview = await coordinator.prepareScopeDelete(
      const SyncTarget('day_book', _bookId),
    );
    expect(preview.count, 2);
    await coordinator.confirmScopeDelete(preview);
    await container.read(daySyncStatusProvider.future);
    expect(container.read(daySyncStatusProvider).hasError, isFalse);
    expect(await container.read(currentDayBookIdProvider.future), hiddenId);
    final copies = await repository.getBooks(accountId: _accountId);
    expect(copies.map((book) => book.id), [hiddenId]);
    final copied = await repository.getEvents(hiddenId);
    expect(copied.map((event) => event.definition.name).toSet(), {
      '原记录',
      '另一设备新增',
    });
    expect(
      copied.every(
        (event) => event.id != _eventId && event.dayBookId == hiddenId,
      ),
      isTrue,
    );
    expect(sent.last.single['payload'], {'expected_full_cursor': '43'});
  });

  test('父本先确认绑定，每个实体仅推队头，后继基线按服务端确认校准', () async {
    await repository.saveEvent(_event('初稿'), accountId: _accountId);
    await repository.saveEvent(_event('最终内容'), accountId: _accountId);
    await service.push();
    expect(sent.length, 3);
    expect(sent[0].single['entity_type'], 'day_book');
    expect(sent[0].single['sync_id'], isNull);
    expect(sent[1].single['sync_id'], _syncId);
    expect(sent[1].single['base_revision'], 0);
    expect(sent[2].single['base_revision'], 1);
    expect((await db.select(db.dayEvents).getSingle()).name, '最终内容');
    expect((await db.select(db.dayEvents).getSingle()).serverRevision, 2);
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
    );
  });

  test('未知创建响应后删除仍重放首次冻结请求，再带真实绑定删除', () async {
    List<Map<String, dynamic>>? original;
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      final wire =
          client.serializers.serializeWith(
                PostSyncPushRequest.serializer,
                request,
              )
              as Map<String, dynamic>;
      final changes = (wire['changes'] as List).cast<Map<String, dynamic>>();
      sent.add(changes);
      if (original == null) {
        original = changes;
        throw DioException(
          requestOptions: RequestOptions(path: '/sync/push'),
          type: DioExceptionType.connectionTimeout,
        );
      }
      final change = changes.single;
      if (change['action'] == 'upsert') expect(changes, original);
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: PostSyncPush200Response(
          (b) => b
            ..serverCursor = '99'
            ..outcomes = ListBuilder([
              PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..entityId = _bookId
                  ..mutationId = change['mutation_id'] as String
                  ..status = change['action'] == 'upsert'
                      ? PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored
                      : PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
                  ..changeId = change['action'] == 'upsert' ? '1' : '2'
                  ..revision = change['action'] == 'upsert' ? 1 : 2
                  ..syncId = _syncId,
              ),
            ]),
        ),
      );
    });
    await expectLater(service.push(), throwsA(isA<DioException>()));
    await repository.deleteBook(await repository.target(_bookId));
    expect(
      (await db.select(db.dayBooks).getSingle()).pendingLocalDelete,
      isTrue,
    );
    await service.push();
    expect(sent.length, 3);
    expect(sent.last.single, containsPair('action', 'delete'));
    expect(sent.last.single, containsPair('sync_id', _syncId));
    expect(sent.last.single, containsPair('base_revision', 1));
    expect((await db.select(db.dayBooks).getSingle()).deletedAt, isNotNull);
  });

  test('条件删本冲突保留本地时仍携带原完整快照边界', () async {
    await service.push();
    await repository.deleteBook(
      await repository.target(_bookId),
      expectedFullCursor: '42',
    );
    statuses[_bookId] = PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
    await service.push();
    final conflict = await db.select(db.syncConflicts).getSingle();
    await service.resolveConflictKeepLocal(conflict.id);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).getSingle();
    expect(jsonDecode(pending.payload), {'expected_full_cursor': '42'});
    expect(pending.baseRevision, 4);
  });

  test('删本冲突采用远端恢复本的可编辑状态', () async {
    await service.push();
    await repository.deleteBook(await repository.target(_bookId));
    statuses[_bookId] = PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict;
    await service.push();
    final conflict = await db.select(db.syncConflicts).getSingle();
    await service.resolveConflictAdoptRemote(conflict.id);
    final book = await db.select(db.dayBooks).getSingle();
    expect(book.pendingLocalDelete, isFalse);
    expect(book.name, '远端');
    expect(book.deletedAt, isNull);
  });

  test('换号后的迟到确认不修改原账号队列或建立绑定', () async {
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final row = await db.select(db.syncChanges).getSingle();
      currentAccount = 'other-account';
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: PostSyncPush200Response(
          (b) => b
            ..serverCursor = '99'
            ..outcomes = ListBuilder([
              PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = row.mutationId
                  ..entityId = _bookId
                  ..status =
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
                  ..changeId = '1'
                  ..revision = 1
                  ..syncId = _syncId,
              ),
            ]),
        ),
      );
    });
    await expectLater(service.push(), throwsStateError);
    expect((await db.select(db.dayBooks).getSingle()).syncId, isNull);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNull);
  });
}
