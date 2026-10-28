import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sesame_notes/data/db.dart';

/// 仅供独立Android验收入口使用，在指定合成笔记的事务提交前暂停。
class ProbeWriteBarrier extends QueryInterceptor {
  /// 入口必须先核验独立测试包身份，正式应用不引用此拦截器。
  ProbeWriteBarrier();

  final _pending = <TransactionExecutor>{};

  /// 只识别指定合成标记的笔记写入，不记录SQL参数或普通业务内容。
  void _track(QueryExecutor executor, String statement, List<Object?> args) {
    if (executor is TransactionExecutor &&
        statement.toLowerCase().contains('memo_entries') &&
        RegExp(
          r'^\s*(insert|update)',
          caseSensitive: false,
        ).hasMatch(statement) &&
        args.any(
          (value) => value is String && value.contains('QA_COMMIT_BARRIER'),
        )) {
      _pending.add(executor);
    }
  }

  /// SQL执行成功后标记事务，外层业务事务仍未提交。
  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final result = await executor.runInsert(statement, args);
      _track(executor, statement, args);
      return result;
    } catch (error, stack) {
      _faultLog('insert_failed', error, stack);
      rethrow;
    }
  }

  /// 更新沿用真实执行器，暂停发生在提交边界。
  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final result = await executor.runUpdate(statement, args);
      _track(executor, statement, args);
      return result;
    } catch (error, stack) {
      _faultLog('update_failed', error, stack);
      rethrow;
    }
  }

  /// 覆盖生产仓储的自定义写语句，保持原SQL及参数不变。
  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      await executor.runCustom(statement, args);
      _track(executor, statement, args);
    } catch (error, stack) {
      _faultLog('custom_failed', error, stack);
      rethrow;
    }
  }

  /// INSERT RETURNING仍属于写入，普通SELECT不会触发暂停。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final result = await executor.runSelect(statement, args);
      _track(executor, statement, args);
      return result;
    } catch (error, stack) {
      _faultLog('select_failed', error, stack);
      rethrow;
    }
  }

  /// 在SQL已写入但事务未提交时给主机发出信号，允许精准强制终止独立测试进程。
  @override
  Future<void> commitTransaction(TransactionExecutor inner) async {
    try {
      if (_pending.remove(inner)) {
        final event = {
          'type': 'PRE_COMMIT_BARRIER',
          'utc': DateTime.now().toUtc().toIso8601String(),
          'pause_ms': 30000,
        };
        final directory = await getApplicationDocumentsDirectory();
        await File(
          '${directory.path}/long-term-precommit.json',
        ).writeAsString(jsonEncode(event), flush: true);
        debugPrintSynchronously(
          'LONG_TERM_ANDROID_FAULT_JSON:${jsonEncode(event)}',
        );
        await Future<void>.delayed(const Duration(seconds: 30));
      }
      await inner.send();
    } catch (error, stack) {
      _faultLog('commit_failed', error, stack);
      rethrow;
    }
  }

  /// 回滚后移除本事务的暂停标记。
  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) async {
    try {
      _pending.remove(inner);
      await inner.rollback();
    } catch (error, stack) {
      _faultLog('rollback_failed', error, stack);
      rethrow;
    }
  }
}

/// 错误日志只包含异常类型与调用栈，避免SQL参数进入日志。
void _faultLog(String phase, Object error, StackTrace stack) {
  debugPrintSynchronously(
    'LONG_TERM_ANDROID_FAULT_JSON:${jsonEncode({'type': 'error', 'phase': phase, 'error_type': error.runtimeType.toString(), 'stack': stack.toString()})}',
  );
}

/// 重启后只核对明确合成QA标记的笔记，并验证数据库结构完整性。
Future<void> emitAndroidRecoveryAudit(SesameDatabase db) async {
  try {
    final notes = await db
        .customSelect(
          "SELECT id,memo_book_id,title,body,updated_at FROM memo_entries WHERE deleted_at IS NULL AND (title LIKE 'QA_%' OR body LIKE '%QA_%') ORDER BY id",
        )
        .get();
    final integrity =
        (await db.customSelect('PRAGMA integrity_check').getSingle())
            .data
            .values
            .single;
    final foreignKeys = await db.customSelect('PRAGMA foreign_key_check').get();
    final directory = await getApplicationDocumentsDirectory();
    final marker = File('${directory.path}/long-term-precommit.json');
    debugPrintSynchronously(
      'LONG_TERM_ANDROID_FAULT_JSON:${jsonEncode({'type': 'recovery_audit', 'utc': DateTime.now().toUtc().toIso8601String(), 'precommit_marker_present': await marker.exists(), 'notes': notes.map((row) => row.data).toList(), 'integrity': integrity, 'foreign_key_errors': foreignKeys.length})}',
    );
    if (integrity != 'ok' || foreignKeys.isNotEmpty) {
      throw StateError('验收数据库完整性核对失败');
    }
  } catch (error, stack) {
    _faultLog('audit_failed', error, stack);
    rethrow;
  }
}
