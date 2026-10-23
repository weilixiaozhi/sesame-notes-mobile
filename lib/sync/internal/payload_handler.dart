import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:built_value/json_object.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'sync_runtime.dart';

/// 记账实体的同步载荷与金额规范化。
class AccountingPayloadCodec {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  AccountingPayloadCodec(this._runtime);
  final SyncRuntime _runtime;

  /// 未冻结请求只读取队列的权威 UTC 毫秒；已冻结请求由发送器原样重放。
  DateTime _lwwUpdatedAt(SyncChange change) {
    try {
      final precise = change.updatedAt.toUtc();
      if (precise.year < 1 || precise.year > 9999) {
        throw const FormatException('队列编辑时间超出有效范围');
      }
      return DateTime.fromMillisecondsSinceEpoch(
        precise.millisecondsSinceEpoch,
        isUtc: true,
      );
    } catch (error, stackTrace) {
      logger.error(
        'SyncService',
        '队列编辑时间校验失败：type=${change.entityType}，mutation=${change.mutationId}',
        error.runtimeType,
        stackTrace,
      );
      Error.throwWithStackTrace(
        change.frozenRequest != null
            ? const SyncOperationFailure(
                code: 'SYNC_FROZEN_REQUEST_INVALID',
                message: '待确认上传请求的时间信息无效，原记录已保留，请反馈此问题。',
              )
            : const SyncOperationFailure(
                code: 'SYNC_EDIT_TIME_INVALID',
                message: '这条记录的编辑时间无法读取，数据已保留；请编辑原记录并保存后重试。',
              ),
        stackTrace,
      );
    }
  }

  /// 读取分类变更 payload 的层级；解析失败排到最后，不阻塞推送主流程。
  int categoryLevelOf(String rawPayload) {
    try {
      final data = jsonDecode(rawPayload) as Map<String, dynamic>;
      return categoryLevel(data['level']);
    } catch (_) {
      // 载荷解析失败不影响推送主流程，按最低优先级处理
    }
    return 99;
  }

  /// 构造本地实体最新值的交易 payload（member 直写契约，冲突解决专用）。
  Future<String> localTxPayload(dynamic tx) async {
    final splits = await (_runtime.db.select(
      _runtime.db.transactionSplits,
    )..where((s) => s.transactionId.equals(tx.id as String))).get();
    return jsonEncode({
      'tx_type': tx.txType,
      'amount': tx.amount,
      'happened_at': (tx.happenedAt as DateTime).toUtc().toIso8601String(),
      'note': tx.note,
      'category_id': tx.categoryId,
      'currency_code': tx.currencyCode,
      'native_amount': tx.nativeAmount,
      'recurring_id': tx.recurringId,
      'occurrence_date': tx.occurrenceDate,
      'payer_member_id': tx.payerMemberId,
      'aa_mode': tx.aaMode?.toString(),
      'splits': [
        for (final s in splits) {'member_id': s.memberId, 'amount': s.amount},
      ],
      'last_edited_at': (tx.lastEditedAt as DateTime?)
          ?.toUtc()
          .toIso8601String(),
    });
  }

  /// 执行toChangeInner对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner toChangeInner(
    SyncChange ch,
    Map<String, String> syncIdByLedger,
  ) {
    // 账本级变更携带同步身份；user 级实体（category/rate）无账本边界，不带
    final syncId = ch.ledgerId == null ? null : syncIdByLedger[ch.ledgerId];
    // base_revision 由队列行携带（ChangeRecorder 按同实体 FIFO 链计算）
    switch (ch.entityType) {
      case 'ledger':
        return ledgerChange(ch, syncId);
      case 'ledger_archive':
        // 显式绑定归档变体，生成联合类型的反序列化结果不能直接用于再次序列化。
        return PostSyncPushRequestChangesInner(
          (b) => b
            ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf3>(
              value: _runtime.deser(
                jsonEncode({
                  'mutation_id': ch.mutationId,
                  'entity_type': 'ledger_archive',
                  'entity_id': ch.entityId,
                  'ledger_id': ch.ledgerId,
                  'sync_id': syncId,
                  'action': 'upsert',
                  'updated_at': _lwwUpdatedAt(ch).toIso8601String(),
                  'payload': jsonDecode(ch.payload),
                }),
                PostSyncPushRequestChangesInnerAnyOf3.serializer,
              ),
            ),
        );
      case 'transaction':
        return transactionChange(ch, syncId);
      case 'category':
        return categoryChange(ch);
      case 'recurring_transaction':
        return recurringChange(ch, syncId);
      case 'exchange_rate_override':
        return overrideChange(ch);
      case 'member':
        return memberChange(ch, syncId);
      default:
        throw StateError('未知 entityType: ');
    }
  }

  /// 执行ledgerChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner ledgerChange(SyncChange ch, String? syncId) {
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
            value: PostSyncPushRequestChangesInnerAnyOf2(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf1>(
                  value: _runtime.deser(
                    jsonEncode({
                      'mutation_id': ch.mutationId,
                      'entity_type': 'ledger',
                      'entity_id': ch.entityId,
                      'ledger_id': ch.ledgerId ?? ch.entityId,
                      'sync_id': ?syncId,
                      'base_revision': ?ch.baseRevision,
                      'action': 'delete',
                      'updated_at': updatedAt.toIso8601String(),
                      'payload': jsonDecode(ch.payload),
                    }),
                    PostSyncPushRequestChangesInnerAnyOf2AnyOf1.serializer,
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
          value: PostSyncPushRequestChangesInnerAnyOf2(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf2AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
                            .ledger
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId ?? ch.entityId
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
                        >(
                          ch.payload,
                          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 执行transactionChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner transactionChange(
    SyncChange ch,
    String? syncId,
  ) {
    // 推送出口对齐服务端契约：amount/native_amount 必须为规范化 decimal
    //（尾零剥离，如 "857.00" → "857"）。
    final payload = normalizeTransactionAmounts(ch.payload);
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4>(
            value: PostSyncPushRequestChangesInnerAnyOf4(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf4AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum
                              .transaction
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum
                              .delete
                      ..updatedAt = updatedAt
                      ..payload = JsonObject(jsonDecode(payload)),
                  ),
                ),
            ),
          ),
      );
    }
    // SDK 会把不存在的日历日期滚动到下个月，首次上行必须先拒绝这种正文改写。
    // 删除只使用实体身份；冻结请求按原字节确认，其模型转换只用于读取元数据。
    if (ch.frozenRequest == null) {
      final occurrenceDate =
          (jsonDecode(payload) as Map<String, dynamic>)['occurrence_date'];
      if (occurrenceDate != null) {
        final parsed =
            occurrenceDate is String &&
                RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(occurrenceDate)
            ? DateTime.tryParse('${occurrenceDate}T00:00:00Z')
            : null;
        if (parsed == null ||
            parsed.toIso8601String().substring(0, 10) != occurrenceDate) {
          throw const SyncOperationFailure(
            code: 'SYNC_OCCURRENCE_DATE_INVALID',
            message: '周期记账的发生日期无效，原记录已保留；请编辑关联记录后重试。',
          );
        }
      }
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4>(
          value: PostSyncPushRequestChangesInnerAnyOf4(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf4AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum
                            .transaction
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
                        >(
                          payload,
                          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 把交易 payload 的金额字段规范化为契约格式（尾零剥离，如 "857.00" → "857"）。
  ///
  /// 服务端金额契约要求规范化 decimal；推送出口统一归一
  /// （尾零剥离，如 "857.00" → "857"），避免整批因单条金额格式被 400 拒绝。
  String normalizeTransactionAmounts(String rawPayload) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(rawPayload) as Map<String, dynamic>;
    } catch (_) {
      return rawPayload;
    }
    for (final key in const ['amount', 'native_amount']) {
      final value = data[key];
      if (value is String) {
        final parsed = Decimal.tryParse(value);
        if (parsed != null) data[key] = normalizeDecimal(parsed);
      }
    }
    // 指定分摊行金额同口径规范化。
    final splits = data['splits'];
    if (splits is List) {
      for (final split in splits) {
        if (split is Map<String, dynamic>) {
          final amount = split['amount'];
          if (amount is String) {
            final parsed = Decimal.tryParse(amount);
            if (parsed != null) split['amount'] = normalizeDecimal(parsed);
          }
        }
      }
    }
    return jsonEncode(data);
  }

  /// 执行categoryChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner categoryChange(SyncChange ch) {
    // 分类正文独立于队列时钟，旧本地 ISO 和缺省时间不会影响请求包络。
    final payload = jsonDecode(ch.payload) as Map<String, dynamic>;
    // HTTP 契约是三位毫秒 UTC；Dart 原始时钟可能还含微秒。
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5>(
            value: PostSyncPushRequestChangesInnerAnyOf5(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf5AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf5AnyOf1EntityTypeEnum
                              .category
                      ..entityId = ch.entityId
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf5AnyOf1ActionEnum
                              .delete
                      ..updatedAt = updatedAt
                      ..payload = JsonObject(payload),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5>(
          value: PostSyncPushRequestChangesInnerAnyOf5(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf5AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum
                            .category
                    ..entityId = ch.entityId
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
                        >(
                          ch.payload,
                          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 执行recurringChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner recurringChange(
    SyncChange ch,
    String? syncId,
  ) {
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf6>(
            value: PostSyncPushRequestChangesInnerAnyOf6(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf6AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf6AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf6AnyOf1EntityTypeEnum
                              .recurringTransaction
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf6AnyOf1ActionEnum
                              .delete
                      ..updatedAt = updatedAt
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    // 普通规则编辑只发送排期元数据，生成进度由发生记录与初始历史状态承载。
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf6>(
          value: PostSyncPushRequestChangesInnerAnyOf6(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf6AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf6AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
                            .recurringTransaction
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
                        >(
                          ch.payload,
                          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 执行overrideChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner overrideChange(SyncChange ch) {
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf7>(
            value: PostSyncPushRequestChangesInnerAnyOf7(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf7AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf7AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf7AnyOf1EntityTypeEnum
                              .exchangeRateOverride
                      ..entityId = ch.entityId
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf7AnyOf1ActionEnum
                              .delete
                      ..updatedAt = updatedAt
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf7>(
          value: PostSyncPushRequestChangesInnerAnyOf7(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf7AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf7AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum
                            .exchangeRateOverride
                    ..entityId = ch.entityId
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload
                        >(
                          ch.payload,
                          PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 执行memberChange对应的同步步骤，沿用所属域的身份与事务规则。
  PostSyncPushRequestChangesInner memberChange(SyncChange ch, String? syncId) {
    final updatedAt = _lwwUpdatedAt(ch);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf8>(
            value: PostSyncPushRequestChangesInnerAnyOf8(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf8AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf8AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf8AnyOf1EntityTypeEnum
                              .member
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf8AnyOf1ActionEnum
                              .delete
                      ..updatedAt = updatedAt
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf8>(
          value: PostSyncPushRequestChangesInnerAnyOf8(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf8AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf8AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum
                            .member
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum
                            .upsert
                    ..updatedAt = updatedAt
                    ..payload = _runtime
                        .deser<
                          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
                        >(
                          ch.payload,
                          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
                              .serializer,
                        )
                        .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 解析分类层级：只接受 1/2（数值或字符串枚举形态），其余一律拒绝。
  int categoryLevel(Object? value) {
    if (value is num) {
      // 先按数值验证枚举，避免小数截断后变成有效层级。
      if (value == 1 || value == 2) return value.toInt();
    } else if (value is String) {
      final level = int.tryParse(value);
      if (level != null && (level == 1 || level == 2)) return level;
    }
    throw const FormatException('分类同步事件 level 非法');
  }

  /// 提取删除事件的 deleted_at：payload 优先，缺失回退事件 updated_at。
  DateTime deleteTime(Map<String, dynamic> p) {
    return DateTime.tryParse(p['deleted_at']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();
  }
}
