import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/database_fingerprint.dart';

void main() {
  late SesameDatabase db;
  final now = DateTime.utc(2026, 9, 13);
  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: 'book',
            name: 'book',
            type: 'normal',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.batch(
      (batch) => batch.insertAll(db.memoEntries, [
        for (var i = 0; i < 40; i++)
          MemoEntriesCompanion.insert(
            id: 'entry-$i',
            memoBookId: 'book',
            bookType: 'normal',
            title: '$i',
            body: d.Value(
              jsonEncode({
                'ops': [
                  {'insert': '${'字' * 4096}\n'},
                ],
              }),
            ),
            bodyFormat: const d.Value('delta_v1'),
            createdAt: now,
            updatedAt: now,
          ),
      ]),
    );
  });
  tearDown(() => db.close());
  Map<String, List<FingerprintTable>> getGroups() => {
    'book': [
      const FingerprintTable('memo_books', 'id', 'book'),
      const FingerprintTable('memo_entries', 'memo_book_id', 'book'),
    ],
  };
  test('分批摘要稳定、只返回固定长度哈希，并发现正文修改', () async {
    final first = await fingerprintGroups(db, getGroups());
    expect(first['book']!.length, 64);
    expect(await fingerprintGroups(db, getGroups()), first);
    await (db.update(
      db.memoEntries,
    )..where((e) => e.id.equals('entry-1'))).write(
      const MemoEntriesCompanion(
        body: d.Value('{"ops":[{"insert":"changed\\n"}]}'),
      ),
    );
    expect(await fingerprintGroups(db, getGroups()), isNot(first));
  });
  test('事务内看到未提交变化，回滚后恢复原摘要且不挂起', () async {
    final first = await fingerprintGroups(db, getGroups());
    await expectLater(
      db.transaction(() async {
        await (db.update(db.memoEntries)..where((e) => e.id.equals('entry-1')))
            .write(const MemoEntriesCompanion(title: d.Value('change')));
        expect(await fingerprintGroups(db, getGroups()), isNot(first));
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await fingerprintGroups(db, getGroups()), first);
  });
  test('取消读取释放工作连接，之后数据库仍可正常查询', () async {
    final cancelled = Completer<void>()..complete();
    await expectLater(
      fingerprintGroups(db, getGroups(), cancelled: cancelled.future),
      throwsStateError,
    );
    expect((await db.select(db.memoEntries).get()).length, 40);
  });
}
