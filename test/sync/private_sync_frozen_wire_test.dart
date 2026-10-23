import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart' as fitness;
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/fitness_space_fixture.dart';
import '../helpers/test_isolation.dart';

const _account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _otherAccount = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const _parent = '11111111-1111-4111-8111-111111111111';
const _entity = '22222222-2222-4222-8222-222222222222';
const _mutation = '33333333-3333-4333-8333-333333333333';
const _updated = '2026-10-16T01:02:03.123Z';

/// 通过生产上传流程和真实 Dio 字节确认三域协议转换不会改写已冻结请求。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncService service;
  late _PrivateFrozenWireAdapter adapter;
  late String account;

  setUp(() {
    try {
      resetGlobalTestState();
      account = _account;
      db = SesameDatabase.withExecutor(NativeDatabase.memory());
      adapter = _PrivateFrozenWireAdapter(db);
      client = api.SesameApiClient(basePathOverride: 'https://private.test');
      client.dio.httpClientAdapter = adapter;
      service = SyncService(
        client: client,
        db: db,
        deviceId: 'device',
        currentAccountIdGetter: () => account,
        dayRepository: DayRepository(
          db,
          validateAndProject: DayDateRules().validateAndProject,
        ),
        memoRepository: MemoRepository(db),
        fitnessEnabled: true,
      );
    } catch (error, stackTrace) {
      logger.error('PrivateFrozenWireTest', '私有域同步夹具初始化失败', error, stackTrace);
      rethrow;
    }
  });

  tearDown(() async {
    try {
      client.dio.close(force: true);
      await db.close();
    } catch (error, stackTrace) {
      logger.error('PrivateFrozenWireTest', '私有域同步夹具清理失败', error, stackTrace);
      rethrow;
    }
  });

  for (final type in ['day_event', 'memo_entry', 'fitness_template']) {
    test('$type 丢回执、换号和重试保留冻结原文字节与身份', () async {
      try {
        final payload = await _seedEntity(db, type);
        // 模拟已发送的旧版本正文：未知字段和显式空值不能经 DTO 重建丢失。
        final frozenPayload = {
          ...payload,
          'retired_metadata': {'value': null, 'text': '保留原文😀'},
        };
        final frozen = const JsonEncoder.withIndent('  ').convert({
          'mutation_id': _mutation,
          'entity_type': type,
          'entity_id': _entity,
          'ledger_id': null,
          'day_book_id': type == 'day_event' ? _parent : null,
          'memo_book_id': type == 'memo_entry' ? _parent : null,
          'fitness_space_id': type == 'fitness_template' ? _parent : null,
          'sync_id': testFitnessBinding,
          'base_revision': 1,
          'action': 'upsert',
          'updated_at': _updated,
          'payload': frozenPayload,
        });
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: type,
                entityId: _entity,
                dayBookId: d.Value(type == 'day_event' ? _parent : null),
                memoBookId: d.Value(type == 'memo_entry' ? _parent : null),
                fitnessSpaceId: d.Value(
                  type == 'fitness_template' ? _parent : null,
                ),
                accountId: const d.Value(_account),
                action: 'upsert',
                payload: jsonEncode(payload),
                updatedAt: DateTime.parse(_updated),
                mutationId: _mutation,
                baseRevision: const d.Value(1),
                frozenRequest: d.Value(frozen),
              ),
            );
        final original = await db.select(db.syncChanges).getSingle();
        final expectedBytes = utf8.encode(
          '{"device_id":"device","changes":[$frozen]}',
        );

        await expectLater(service.push(), throwsA(isA<DioException>()));
        expect(await db.select(db.syncChanges).getSingle(), original);
        expect(adapter.bodies.single, orderedEquals(expectedBytes));

        // 另一账号既不能发送原账号的未知结果，也不能改变其冻结材料。
        account = _otherAccount;
        await service.push();
        expect(adapter.bodies, hasLength(1));
        expect(await db.select(db.syncChanges).getSingle(), original);

        account = _account;
        await service.push();
        expect(adapter.bodies, hasLength(2));
        for (final bytes in adapter.bodies) {
          expect(bytes, orderedEquals(expectedBytes));
        }
        expect(adapter.pendingBeforeReply, [original, original]);
        final acknowledged = await db.select(db.syncChanges).getSingle();
        expect(acknowledged.pushedAt, isNotNull);
        expect(acknowledged.mutationId, _mutation);
        expect(acknowledged.accountId, _account);
      } catch (error, stackTrace) {
        logger.error(
          'PrivateFrozenWireTest',
          '私有域冻结原文回归失败：type=$type',
          error,
          stackTrace,
        );
        rethrow;
      }
    });
  }
}

/// 创建最小的真实父范围和子实体，确保冻结读取与确认都执行原有归属校验。
Future<Map<String, Object?>> _seedEntity(SesameDatabase db, String type) async {
  try {
    final instant = DateTime.parse(_updated);
    switch (type) {
      case 'day_event':
        await db
            .into(db.dayBooks)
            .insert(
              DayBooksCompanion.insert(
                id: _parent,
                name: '日子本',
                storageMode: const d.Value('cloud'),
                scopeAccountId: const d.Value(_account),
                syncId: const d.Value(testFitnessBinding),
                serverRevision: const d.Value(1),
                fullCursor: const d.Value('1'),
                createdAt: instant,
                updatedAt: instant,
              ),
            );
        await db
            .into(db.dayEvents)
            .insert(
              DayEventsCompanion.insert(
                id: _entity,
                dayBookId: _parent,
                name: '生日',
                category: 'birthday',
                repeatType: 'yearly',
                statisticType: 'year',
                eventCalendarType: const d.Value('solar'),
                eventOriginalYear: const d.Value(2000),
                eventOriginalMonth: const d.Value(1),
                eventOriginalDay: const d.Value(1),
                eventIsLeapMonth: const d.Value(false),
                eventSolarDate: const d.Value('2000-01-01'),
                serverRevision: const d.Value(1),
                createdAt: instant,
                updatedAt: instant,
              ),
            );
        return {
          'name': '生日',
          'category': 'birthday',
          'repeat_type': 'yearly',
          'statistic_type': 'year',
          'countdown_mode': null,
          'interval_days': null,
          'event': {
            'calendar_type': 'solar',
            'original_year': 2000,
            'original_month': 1,
            'original_day': 1,
            'is_leap_month': false,
            'solar_date': '2000-01-01',
          },
          'start': null,
          'end': null,
          'created_at': _updated,
        };
      case 'memo_entry':
        const body = {
          'ops': [
            {'insert': '备忘录😀\n'},
          ],
        };
        await db
            .into(db.memoBooks)
            .insert(
              MemoBooksCompanion.insert(
                id: _parent,
                name: '备忘录本',
                type: 'normal',
                storageMode: const d.Value('cloud'),
                scopeAccountId: const d.Value(_account),
                syncId: const d.Value(testFitnessBinding),
                serverRevision: const d.Value(1),
                fullCursor: const d.Value('1'),
                createdAt: instant,
                updatedAt: instant,
              ),
            );
        await db
            .into(db.memoEntries)
            .insert(
              MemoEntriesCompanion.insert(
                id: _entity,
                memoBookId: _parent,
                bookType: 'normal',
                title: '备忘录',
                bodyFormat: const d.Value('delta_v1'),
                body: d.Value(jsonEncode(body)),
                serverRevision: const d.Value(1),
                createdAt: instant,
                updatedAt: instant,
              ),
            );
        return {
          'book_type': 'normal',
          'title': '备忘录',
          'body_format': 'delta_v1',
          'body': body,
          'order_key': null,
          'created_at': _updated,
          'updated_at': _updated,
        };
      case 'fitness_template':
        await seedFitnessTestSpace(db, account: _account, id: _parent);
        final payload = fitness.FitnessTemplate(
          id: _entity,
          name: '健身模板',
          exercises: const [],
          createdAt: instant,
          updatedAt: instant,
        ).toJson();
        await db
            .into(db.fitnessEntities)
            .insert(
              FitnessEntitiesCompanion.insert(
                id: _entity,
                fitnessSpaceId: _parent,
                entityType: type,
                scopeAccountId: const d.Value(_account),
                storageMode: const d.Value('cloud'),
                syncId: const d.Value(testFitnessBinding),
                serverRevision: const d.Value(1),
                payload: jsonEncode(payload),
                createdAt: instant,
                updatedAt: instant,
              ),
            );
        return payload;
      default:
        throw StateError('不支持的私有域测试实体');
    }
  } catch (error, stackTrace) {
    logger.error('PrivateFrozenWireTest', '私有域实体夹具保存失败', error, stackTrace);
    rethrow;
  }
}

/// 记录生产 Dio 的完整请求字节，在首次提交丢回执后返回同一 mutation 的确认。
class _PrivateFrozenWireAdapter implements HttpClientAdapter {
  /// 使用同一个数据库读取确认前的冻结队列，避免受确认后的正文清理影响。
  _PrivateFrozenWireAdapter(this.db);

  final SesameDatabase db;
  final bodies = <Uint8List>[];
  final pendingBeforeReply = <SyncChange>[];

  /// 首次请求模拟响应丢失，随后按实际发送身份返回成功确认。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      if (options.path != '/api/v1/sync/push' || requestStream == null) {
        throw StateError('私有域同步测试出现未预期请求');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk in requestStream) {
        bytes.add(chunk);
      }
      final sent = bytes.takeBytes();
      bodies.add(sent);
      final body = jsonDecode(utf8.decode(sent)) as Map;
      final change = (body['changes'] as List).single as Map;
      final pending = await db.select(db.syncChanges).getSingle();
      pendingBeforeReply.add(pending);
      expect(change['mutation_id'], pending.mutationId);
      expect(change['updated_at'], _updated);
      expect(pending.accountId, _account);
      if (bodies.length == 1) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return ResponseBody.fromString(
        jsonEncode({
          'server_cursor': '2',
          'outcomes': [
            {
              'mutation_id': change['mutation_id'],
              'entity_id': change['entity_id'],
              'status': 'accepted',
              'revision': 2,
              'sync_id': testFitnessBinding,
              'change_id': '2',
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    } catch (error, stackTrace) {
      logger.error(
        'PrivateFrozenWireTest',
        '私有域同步网络夹具失败',
        error.runtimeType,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 请求夹具不持有额外网络资源。
  @override
  void close({bool force = false}) {}
}
