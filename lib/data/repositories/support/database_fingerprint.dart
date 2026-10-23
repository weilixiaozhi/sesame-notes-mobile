import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../../db.dart';

/// 名称与过滤条件由内部调用方提供，值通过参数绑定。
class FingerprintTable {
  const FingerprintTable(
    this.table,
    this.column,
    this.value, {
    this.filter = '1=1',
  });
  final String table, column, value, filter;
}

/// 同一读事务里分批散列；界面只收到摘要，不常驻完整本的 JSON。
Future<Map<String, String>> fingerprintGroups(
  SesameDatabase db,
  Map<String, List<FingerprintTable>> groups, {
  Set<String> absentIfMissing = const {},
  Future<void>? cancelled,
}) async {
  if (groups.isEmpty) return {};
  final control = cancelled == null ? null : ReceivePort();
  if (control != null) {
    unawaited(
      control.first
          .then((port) {
            unawaited(cancelled!.then((_) => (port as SendPort).send(true)));
          })
          .catchError((Object _) {}),
    );
  }
  // 单独构造闭包，不能把原生数据库句柄随外层作用域捕获进工作 isolate。
  final computation = _computation(groups, absentIfMissing, control?.sendPort);
  try {
    return await db.transaction(
      () => db.computeWithDatabase<Map<String, String>, SesameDatabase>(
        connect: _FingerprintDatabase.new,
        computation: computation,
      ),
    );
  } finally {
    control?.close();
  }
}

Future<Map<String, String>> Function(SesameDatabase) _computation(
  Map<String, List<FingerprintTable>> groups,
  Set<String> absent,
  SendPort? owner,
) => (db) async {
  final receiver = owner == null ? null : ReceivePort();
  var cancelled = false;
  final subscription = receiver?.listen((_) => cancelled = true);
  if (receiver != null) owner!.send(receiver.sendPort);
  void check() {
    if (cancelled) throw StateError('快照读取已取消');
  }

  try {
    final result = <String, String>{};
    for (final group in groups.entries) {
      check();
      result[group.key] = await _fingerprint(
        db,
        group.value,
        absent.contains(group.key),
        check,
      );
    }
    return result;
  } finally {
    await subscription?.cancel();
    receiver?.close();
  }
};

class _FingerprintDatabase extends SesameDatabase {
  _FingerprintDatabase(DatabaseConnection super.connection)
    : super.withExecutor();
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async => throw StateError('指纹读取不能创建数据库'),
    onUpgrade: (_, _, _) async => throw StateError('指纹读取不能迁移数据库'),
    beforeOpen: (_) async {},
  );
}

Future<String> _fingerprint(
  SesameDatabase db,
  List<FingerprintTable> scopes,
  bool absentIfMissing,
  void Function() check,
) async {
  final result = StreamController<Digest>();
  final digest = result.stream.single;
  final input = sha256.startChunkedConversion(result.sink);
  try {
    for (var scopeIndex = 0; scopeIndex < scopes.length; scopeIndex++) {
      check();
      final scope = scopes[scopeIndex];
      final table = db.allTables.firstWhere(
        (t) => t.actualTableName == scope.table,
      );
      final columns = table.$columns.map((c) => c.$name).toList()..sort();
      if (!columns.contains(scope.column)) throw ArgumentError('无效指纹范围');
      final info = await db
          .customSelect('PRAGMA table_info("${scope.table}")')
          .get();
      final keyColumns = info.where((r) => r.read<int>('pk') > 0).toList()
        ..sort((a, b) => a.read<int>('pk').compareTo(b.read<int>('pk')));
      final keys = keyColumns.map((r) => r.read<String>('name')).toList();
      if (keys.isEmpty) throw StateError('指纹表缺少主键');
      final order = keys.map((k) => '"$k"').join(',');
      input.add(
        utf8.encode(
          jsonEncode([scope.table, scope.column, scope.value, scope.filter]),
        ),
      );
      List<Object?>? cursor;
      while (true) {
        check();
        final rows = await db
            .customSelect(
              'SELECT ${columns.map((c) => '"$c"').join(',')} FROM "${scope.table}" WHERE "${scope.column}"=? AND (${scope.filter}) ${cursor == null ? '' : 'AND ($order)>(${List.filled(keys.length, '?').join(',')})'} ORDER BY $order LIMIT 16',
              variables: [
                Variable(scope.value),
                if (cursor != null)
                  ...cursor.map(
                    (v) => v is int
                        ? Variable<int>(v)
                        : Variable<String>(v as String?),
                  ),
              ],
            )
            .get();
        check();
        if (rows.isEmpty &&
            cursor == null &&
            scopeIndex == 0 &&
            absentIfMissing) {
          return 'absent';
        }
        for (final row in rows) {
          input.add(utf8.encode(jsonEncode(row.data)));
          input.add(const [10]);
        }
        if (rows.length < 16) break;
        cursor = keys.map((key) => rows.last.data[key]).toList();
      }
    }
  } finally {
    input.close();
  }
  return (await digest).toString();
}
