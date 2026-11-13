import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/memo_media_repository.dart';

/// 1x1 PNG：格式识别与字节往返只需要真实签名和可解码内容。
final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late MemoMediaRepository repository;
  const entry = '33333333-3333-4333-8333-333333333333';
  const book = '11111111-1111-4111-8111-111111111111';
  const media = '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c';

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = MemoMediaRepository(db);
  });
  tearDown(() => db.close());

  /// 创建一条真实笔记，供正文引用检查使用。
  Future<void> seedEntry(String body) async {
    final now = DateTime.utc(2026, 11, 13);
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: book,
            name: '图片测试',
            type: 'normal',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.memoEntries)
        .insert(
          MemoEntriesCompanion.insert(
            id: entry,
            memoBookId: book,
            bookType: 'normal',
            title: '图片测试',
            body: d.Value(body),
            bodyFormat: d.Value('delta_v1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('图片字节与摘要按标识读写，格式只由签名判断', () async {
    expect(memoMediaMimeOf(_png), 'image/png');
    expect(
      memoMediaMimeOf(Uint8List.fromList(utf8.encode('not-an-image'))),
      null,
    );
    final item = await repository.upsert(
      id: media,
      entryId: entry,
      scopeAccountId: null,
      mime: 'image/png',
      bytes: _png,
      sha256: memoMediaSha256(_png),
      uploadState: 'local',
    );
    expect(item.bytes, _png);
    final loaded = await repository.byId(media);
    expect(loaded, isNotNull);
    expect(loaded!.sha256, memoMediaSha256(_png));
    expect(loaded.uploadState, 'local');
  });

  test('待上传列表只返回本笔记未确认的云端图片', () async {
    for (final (id, state) in [
      ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'pending'),
      ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'failed'),
      ('cccccccc-cccc-4ccc-8ccc-cccccccccccc', 'uploaded'),
      ('dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'local'),
    ]) {
      await repository.upsert(
        id: id,
        entryId: entry,
        scopeAccountId: state == 'local' ? null : 'account',
        mime: 'image/png',
        bytes: _png,
        sha256: memoMediaSha256(_png),
        uploadState: state,
      );
    }
    final pending = await repository.pendingUploads(entry);
    expect(pending.map((item) => item.id).toSet(), {
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    });
  });

  test('回收未被正文引用的过期图片，保留仍被引用的图片', () async {
    await seedEntry(
      jsonEncode({
        'ops': [
          {
            'insert': {'memo_image': media},
          },
          {'insert': '\n'},
        ],
      }),
    );
    final other = 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee';
    for (final id in [media, other]) {
      await repository.upsert(
        id: id,
        entryId: entry,
        scopeAccountId: null,
        mime: 'image/png',
        bytes: _png,
        sha256: memoMediaSha256(_png),
        uploadState: 'local',
      );
    }
    // 宽限期外的图片才可回收。
    final old = DateTime.utc(2026, 11, 1);
    await db
        .update(db.memoMedia)
        .write(MemoMediaCompanion(createdAt: d.Value(old)));
    await repository.cleanupForEntry(entry, {media});
    expect(await repository.byId(media), isNotNull);
    expect(await repository.byId(other), isNull);
  });
}
