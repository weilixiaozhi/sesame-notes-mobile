import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/sync/internal/payload_handler.dart';
import 'package:sesame_notes/sync/internal/sync_runtime.dart';

const _entities = [
  'ledger',
  'ledger_archive',
  'transaction',
  'category',
  'recurring_transaction',
  'exchange_rate_override',
  'member',
];
const _precise = '2026-10-11T01:02:03.789654Z';

/// 构造各实体的必填业务字段，编辑时间由单独用例明确指定。
Map<String, Object?> _payload(String entity) => switch (entity) {
  'ledger' => {
    'name': '云账本',
    'currency': 'CNY',
    'month_start_day': 1,
    'aa_enabled': false,
  },
  'ledger_archive' => {'archived': true},
  'transaction' => {
    'tx_type': 'expense',
    'amount': '12',
    'native_amount': '12',
    'currency_code': 'CNY',
    'happened_at': '2026-10-01T00:00:00.000Z',
    'category_id': null,
    'note': null,
    'payer_member_id': null,
    'aa_mode': null,
    'splits': null,
  },
  'category' => {
    'name': '饮食',
    'kind': 'expense',
    'level': '1',
    'sort_order': 0,
    'icon': null,
    'parent_id': null,
  },
  'recurring_transaction' => {
    'tx_type': 'expense',
    'amount': '12',
    'currency_code': 'CNY',
    'category_id': null,
    'note': null,
    'frequency': 'daily',
    'interval': 1,
    'day_of_month': null,
    'day_of_week': null,
    'month_of_year': null,
    'start_date': '2026-10-01T00:00:00.000Z',
    'end_date': null,
    'protocol_version': 1,
    'time_zone': 'Asia/Shanghai',
    'enabled': true,
  },
  'exchange_rate_override' => {
    'base_currency': 'USD',
    'quote_currency': 'CNY',
    'rate': '7',
  },
  'member' => {'display_name': '成员'},
  _ => throw StateError('未知测试实体'),
};

/// 队列时间是未冻结请求的唯一权威，正文中的同名字段仅属于业务快照。
SyncChange _change(
  String entity,
  String action,
  Map<String, Object?> payload, {
  DateTime? updatedAt,
}) => SyncChange(
  id: 1,
  entityType: entity,
  entityId: 'entity-id',
  ledgerId:
      [
        'ledger',
        'ledger_archive',
        'transaction',
        'recurring_transaction',
        'member',
      ].contains(entity)
      ? 'ledger-id'
      : null,
  action: action,
  payload: jsonEncode(payload),
  updatedAt: updatedAt ?? DateTime.parse(_precise),
  mutationId: 'mutation-id',
);

/// 各实体统一使用 UTC 毫秒队列时间，旧正文的时区表示不能改写上传顺序。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late SyncRuntime runtime;
  late AccountingPayloadCodec codec;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient(basePathOverride: 'https://unused.test');
    runtime = SyncRuntime(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
      sessionGenerationGetter: null,
      generation: null,
    );
    codec = AccountingPayloadCodec(runtime);
  });
  tearDown(() async {
    try {
      client.dio.close(force: true);
      await db.close();
    } catch (error, stackTrace) {
      logger.error('PayloadTimeTest', '同步时间测试连接清理失败', error, stackTrace);
      rethrow;
    }
  });

  /// 使用正式生成模型序列化出口，验证实际 envelope 的 UTC 毫秒时间。
  Map<String, dynamic> wire(SyncChange change) => runtime.modelMap(
    codec.toChangeInner(change, {'ledger-id': 'cloud-id'}),
    api.PostSyncPushRequestChangesInner.serializer,
  );

  for (final entity in _entities) {
    for (final action
        in entity == 'ledger_archive' ? ['upsert'] : ['upsert', 'delete']) {
      test('$entity $action 首次冻结使用队列 UTC 毫秒时间', () {
        final payload = {..._payload(entity), 'updated_at': _precise};
        final change = _change(entity, action, payload);
        expect(wire(change)['updated_at'], '2026-10-11T01:02:03.789Z');
        expect(jsonDecode(change.payload), payload);
      });
      for (final explicitNull in [false, true]) {
        test('$entity $action 正文时间${explicitNull ? '为 null' : '缺失'}仍正常上传', () {
          final payload = {
            ..._payload(entity),
            if (explicitNull) 'updated_at': null,
          };
          final change = _change(entity, action, payload);
          expect(wire(change)['updated_at'], '2026-10-11T01:02:03.789Z');
          expect(jsonDecode(change.payload), payload);
        });
      }
    }
    test('$entity 正文的不同 UTC 时间不能替代队列时间', () {
      final payload = {
        ..._payload(entity),
        'updated_at': '2000-01-01T00:00:00.000Z',
      };
      final change = _change(entity, 'upsert', payload);
      expect(wire(change)['updated_at'], '2026-10-11T01:02:03.789Z');
      expect(jsonDecode(change.payload), payload);
    });
    for (final invalid in [DateTime.utc(0), DateTime.utc(10000)]) {
      test('$entity 队列编辑时间年份 ${invalid.year} 不合法时给出安全原因', () {
        final change = _change(
          entity,
          'upsert',
          _payload(entity),
          updatedAt: invalid,
        );
        expect(
          () => wire(change),
          throwsA(
            isA<SyncOperationFailure>()
                .having((error) => error.code, '原因码', 'SYNC_EDIT_TIME_INVALID')
                .having(
                  (error) => error.message,
                  '友好提示',
                  '这条记录的编辑时间无法读取，数据已保留；请编辑原记录并保存后重试。',
                ),
          ),
        );
      });
    }
  }

  for (final invalid in [
    123,
    'not-a-time',
    '2026-10-11',
    '2026-10-11T01:02:03.789',
    '0000-10-11T01:02:03.789Z',
    '2026-02-30T01:02:03.789Z',
    '2026-10-11T24:02:03.789Z',
  ]) {
    test('正文冗余时间 $invalid 不参与队列时钟计算', () {
      final change = _change('ledger', 'upsert', {
        ..._payload('ledger'),
        'updated_at': invalid,
      });
      expect(wire(change)['updated_at'], '2026-10-11T01:02:03.789Z');
      expect(jsonDecode(change.payload)['updated_at'], invalid);
    });
  }

  test('结果未知冻结请求的无效年份提示反馈，不引导编辑替换幂等身份', () {
    final change = _change(
      'category',
      'upsert',
      _payload('category'),
      updatedAt: DateTime.utc(0),
    ).copyWith(frozenRequest: const d.Value('{"original":"request"}'));
    expect(
      () => wire(change),
      throwsA(
        isA<SyncOperationFailure>()
            .having((error) => error.code, '原因码', 'SYNC_FROZEN_REQUEST_INVALID')
            .having(
              (error) => error.message,
              '友好提示',
              '待确认上传请求的时间信息无效，原记录已保留，请反馈此问题。',
            ),
      ),
    );
  });
}
