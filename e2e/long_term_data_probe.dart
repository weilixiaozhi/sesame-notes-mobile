/// 在仓库根目录执行 flutter test e2e/long_term_data_probe.dart --no-pub。
/// 使用 Windows Flutter 测试宿主和 Temp 中的独立磁盘 SQLite，输出
/// Temp/long_term_acceptance_results.json；失败详情写入同目录错误日志。
/// 测量应用数据路径，不代表手机冷启动、页面绘制、网络同步或强杀进程体验。
/// 每档三次样本保留原始耗时，适合报告中位数和最大值，不估算尾部百分位。
/// 可用 --dart-define=LONG_TERM_YEARS=1 --dart-define=LONG_TERM_REPEATS=1
/// 运行单档补验；输出文件带 y1_r1 后缀，保留默认九次样本结果。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

import '../test/helpers/fitness_space_fixture.dart';
import '../test/helpers/fitness_transfer_fixture.dart';
import '../test/helpers/test_isolation.dart';

const _ledger = '22222222-2222-4222-8222-000000000001';
const _book = '22222222-2222-4222-8222-000000000002';
const _member = '22222222-2222-4222-8222-000000000003';
const _credentials = '22222222-2222-4222-8222-000000000004';
final _start = DateTime.utc(2016, 1, 1);
const _image =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';
const _yearOption = String.fromEnvironment(
  'LONG_TERM_YEARS',
  defaultValue: '0',
);
const _repeatOption = String.fromEnvironment(
  'LONG_TERM_REPEATS',
  defaultValue: '3',
);
final _onlyYears = int.tryParse(_yearOption) ?? -1;
final _repeats = int.tryParse(_repeatOption) ?? -1;

/// 使用 Flutter 图像解码器验证附件可显示，不只检查 Base64 字节形状。
Future<void> _checkImage(String encoded) async {
  ui.Codec? codec;
  ui.Image? image;
  try {
    codec = await ui.instantiateImageCodec(base64Decode(encoded));
    image = (await codec.getNextFrame()).image;
    expect((image.width, image.height), (1, 1));
  } catch (error, stack) {
    stderr.writeln('合成图片解码失败：$error\n$stack');
    rethrow;
  } finally {
    image?.dispose();
    codec?.dispose();
  }
}

/// 为隔离夹具生成可重复的合法身份，避免样本依赖随机值。
String _id(int value) =>
    '33333333-3333-4333-8333-${value.toString().padLeft(12, '0')}';

/// 生成四笔日账、一篇日记和每周三次训练；长文占十分之一。
Future<void> _seed(SesameDatabase db, int years) async {
  try {
    await _checkImage(_image);
    final memos = MemoRepository(db);
    await memos.createBook(
      id: _book,
      name: '长期隔离验收',
      type: 'normal',
      createdAt: _start,
      updatedAt: _start,
    );
    await memos.createBook(
      id: _credentials,
      name: '合成密码本',
      type: 'credentials',
      createdAt: _start,
      updatedAt: _start,
    );
    final target = await memos.target(_credentials);
    for (var i = 0; i < years * 24; i++) {
      await memos.saveEntry(
        MemoEntry(
          id: _id(400000 + i),
          memoBookId: _credentials,
          bookType: 'credentials',
          title: '虚构站点 $i',
          bodyJson: encodeMemoFields([
            MemoField(label: '账号', value: 'synthetic_$i@example.com'),
            MemoField(label: '密码', value: 'FAKE_$i'),
          ]),
          createdAt: _start,
          updatedAt: _start,
        ),
        target,
        preserveTimes: true,
      );
    }
    final fixture = fitnessFixture();
    fixture.last.payload['custom_exercises'] = [
      {
        'id': 'custom:${_id(900000)}',
        'name': '合成自定义动作',
        'body_part': 'chest',
        'equipment': 'body weight',
        'icon': 'activity',
        'image': _image,
        'deleted': false,
      },
    ];
    await importFitnessFixture(
      db: db,
      document: fitnessDocument(records: fixture),
    );
    // 复用已有健身协议夹具，保留模板、计划、运行中训练、设置及其关系。
    await db.transaction(() async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: _ledger,
              name: '合成日账',
              updatedAt: _start,
            ),
          );
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: _member,
              ledgerId: _ledger,
              displayName: '合成成员',
              memberType: 'PLACEHOLDER',
              updatedAt: _start,
            ),
          );
      await db.batch((batch) {
        for (var i = 0; i < years * 1460; i++) {
          final at = _start.add(Duration(hours: i * 6));
          batch.insert(
            db.transactions,
            TransactionsCompanion.insert(
              id: _id(i),
              ledgerId: _ledger,
              txType: 'expense',
              amount: '12.34',
              happenedAt: at,
              currencyCode: 'CNY',
              nativeAmount: '12.34',
              createdAt: at,
              updatedAt: at,
              payerMemberId: const d.Value(_member),
              note: d.Value('合成账单 $i'),
            ),
          );
        }
        for (var i = 0; i < years * 365; i++) {
          final at = _start.add(Duration(days: i));
          final text = i % 10 == 0
              ? List.filled(400, '多年记录长文🙂与换行。\n').join()
              : '短记 $i\n';
          batch.insert(
            db.memoEntries,
            MemoEntriesCompanion.insert(
              id: _id(100000 + i),
              memoBookId: _book,
              bookType: 'normal',
              title: '合成备忘 $i',
              bodyFormat: const d.Value('delta_v1'),
              body: d.Value(
                jsonEncode({
                  'ops': [
                    {
                      'insert': '标题 $i',
                      'attributes': {'bold': true},
                    },
                    {
                      'insert': '\n',
                      'attributes': {'header': 2},
                    },
                    {'insert': text},
                    {'insert': 'https://example.com'},
                    {'insert': '\n'},
                  ],
                }),
              ),
              createdAt: at,
              updatedAt: at,
            ),
          );
        }
        for (var i = 0; i < years * 156; i++) {
          final payload = fitnessDeepCopy(
            fitnessFixtureWorkout(status: 'completed'),
          );
          final at = _start.add(Duration(days: i * 7 ~/ 3));
          payload.addAll({
            'name': '合成训练 $i',
            'scheduled_date': at.toIso8601String().substring(0, 10),
            'source_kind': 'template',
            'source_plan_id': null,
            'source_plan_name': null,
            'occurrence_key': null,
            'created_at': at.toIso8601String(),
            'updated_at': at.toIso8601String(),
            'run_segments': [
              {
                'started_at': at.toIso8601String(),
                'ended_at': at
                    .add(const Duration(minutes: 45))
                    .toIso8601String(),
              },
            ],
            'exercises': [
              for (var j = 0; j < 4; j++) fitnessFixtureExercise(100 + j * 10),
            ],
          });
          batch.insert(
            db.fitnessEntities,
            FitnessEntitiesCompanion.insert(
              id: _id(200000 + i),
              fitnessSpaceId: testFitnessSpaceId(),
              entityType: 'fitness_workout',
              payload: jsonEncode(payload),
              createdAt: at,
              updatedAt: at,
            ),
          );
        }
      });
    });
  } catch (error, stack) {
    stderr.writeln('合成数据生成失败：$error\n$stack');
    rethrow;
  }
}

/// 对对象键排序，使内容核对忽略 JSON 字段书写顺序，但保留数组顺序。
Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) return value.map(_canonical).toList();
  return value;
}

/// 核对夹具业务字段与父子关系；账单和成员按恢复后的身份映射比较语义。
Future<Map<String, String>> _digests(SesameDatabase db) async {
  try {
    final queries = {
      'transactions':
          'SELECT t.ledger_id,t.tx_type,t.amount,t.currency_code,t.native_amount,t.happened_at,t.note,t.created_at,t.aa_mode,m.display_name AS payer FROM transactions t LEFT JOIN ledger_members m ON t.payer_member_id=m.id ORDER BY t.happened_at,t.note',
      'memos':
          'SELECT id,memo_book_id,book_type,title,body_format,body,created_at,updated_at FROM memo_entries ORDER BY id',
      'fitness':
          'SELECT id,fitness_space_id,entity_type,payload,created_at,updated_at FROM fitness_entities ORDER BY id',
      'members':
          "SELECT ledger_id,display_name,member_type FROM ledger_members WHERE member_type='PLACEHOLDER' ORDER BY display_name",
      'ledger': 'SELECT id,name,currency,storage_mode FROM ledgers ORDER BY id',
      'memo_books':
          'SELECT id,name,type,storage_mode FROM memo_books ORDER BY id',
      'fitness_spaces':
          'SELECT id,name,storage_mode FROM fitness_spaces ORDER BY id',
    };
    final result = <String, String>{};
    for (final entry in queries.entries) {
      final rows = await db.customSelect(entry.value).get();
      final normalized = rows
          .map(
            (row) => {
              for (final field in row.data.entries)
                field.key:
                    (field.key == 'body' || field.key == 'payload') &&
                        field.value is String
                    ? jsonDecode(field.value as String)
                    : field.value,
            },
          )
          .toList();
      result[entry.key] = sha256
          .convert(utf8.encode(jsonEncode(_canonical(normalized))))
          .toString();
    }
    return result;
  } catch (error, stack) {
    stderr.writeln('业务内容校验失败：$error\n$stack');
    rethrow;
  }
}

/// 记录应用代码执行时间，测试加载和编译不进入测量。
Future<T> _measure<T>(
  Map<String, int> sample,
  String key,
  Future<T> Function() action,
) async {
  final timer = Stopwatch()..start();
  try {
    return await action();
  } catch (error, stack) {
    stderr.writeln('验收步骤 $key 失败：$error\n$stack');
    rethrow;
  } finally {
    timer.stop();
    sample[key] = timer.elapsedMicroseconds;
  }
}

/// 在显式调用时运行三个规模档；每档三次独立磁盘恢复并检查完整性。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('多年数据备份和干净库恢复', () async {
    resetGlobalTestState();
    final root = await createTestTempDirectory('long-term-data-');
    final reports = <Map<String, Object?>>[];
    final suffix = _onlyYears == 0 && _repeats == 3
        ? ''
        : '_y${_onlyYears}_r$_repeats';
    try {
      if (![0, 1, 5, 10].contains(_onlyYears) || _repeats < 1 || _repeats > 3) {
        throw const FormatException('年份仅允许1、5、10，重复次数仅允许1至3');
      }
      for (final years in _onlyYears == 0 ? [1, 5, 10] : [_onlyYears]) {
        final sourceFile = File('${root.path}/source-$years.sqlite');
        var source = SesameDatabase.withExecutor(NativeDatabase(sourceFile));
        try {
          await _seed(source, years);
          final expected = await _digests(source);
          final backup = LocalBackupService(
            databaseFile: sourceFile,
            backupDir: Directory('${root.path}/backups-$years'),
          );
          for (var repeat = 0; repeat < _repeats; repeat++) {
            final sample = <String, int>{};
            // 重新打开 SQLite 是连接冷开；操作系统文件缓存不清空，不能当手机冷启动。
            await source.close();
            source = SesameDatabase.withExecutor(NativeDatabase(sourceFile));
            await _measure(
              sample,
              'database_reopen_us',
              () => source
                  .customSelect('SELECT count(*) FROM transactions')
                  .getSingle(),
            );
            final memoRepo = MemoRepository(source);
            await _measure(sample, 'memo_page_100_us', () async {
              expect(
                (await memoRepo.watchEntries(_book, limit: 100).first).length,
                100,
              );
            });
            await _measure(sample, 'credential_search_us', () async {
              final entries = await memoRepo
                  .watchCredentialEntries(
                    bookId: _credentials,
                    search: 'synthetic_1@',
                  )
                  .first;
              expect(entries.length, 1);
            });
            await _measure(sample, 'transaction_page_20_us', () async {
              expect(
                (await LocalTransactionRepository(
                  source,
                ).watchRecentTransactions(ledgerId: _ledger).first).length,
                20,
              );
            });
            await _measure(sample, 'expense_statistics_us', () async {
              final groups = await LocalStatisticsRepository(source)
                  .totalsByCategoryWithHierarchy(
                    ledgerId: _ledger,
                    type: 'expense',
                    start: _start,
                    end: _start.add(Duration(days: years * 366)),
                  );
              expect(
                groups.single.total,
                closeTo(years * 1460 * 12.34, 0.0001),
              );
            });
            await _measure(sample, 'memo_all_read_us', () async {
              expect((await memoRepo.getEntries(_book)).length, years * 365);
            });
            final fitnessRepo = FitnessRepository(
              source,
              spaceId: testFitnessSpaceId(),
            );
            await _measure(sample, 'workout_all_read_us', () async {
              expect((await fitnessRepo.getWorkouts()).length, years * 156 + 2);
            });
            final file = await _measure(
              sample,
              'backup_us',
              () => backup.createBackup(
                db: source,
                trigger: BackupTrigger.automatic,
              ),
            );
            final importer = BackupImportService(tempDirOverride: root);
            final session = await _measure(
              sample,
              'open_preview_us',
              () => importer.openBackup(backupFile: file),
            );
            var live = SesameDatabase.withExecutor(
              NativeDatabase(
                File('${root.path}/restored-$years-$repeat.sqlite'),
              ),
            );
            try {
              session.decisions[_ledger] = RecoveryDecision.restoreLocal;
              session.memoBookDecisions[_book] = RecoveryDecision.restoreLocal;
              session.memoBookDecisions[_credentials] =
                  RecoveryDecision.restoreLocal;
              session.memoTargetSnapshots.addAll(
                await importer.captureMemoTargets(live, [_book, _credentials]),
              );
              for (final space in session.manifest.fitnessSpaces) {
                session.fitnessSpaceDecisions[space.id] =
                    RecoveryDecision.restoreLocal;
                session.fitnessTargetSnapshots[space.id] =
                    await FitnessDataTransfer.fingerprint(live, space.id);
              }
              await _measure(
                sample,
                'restore_us',
                () => importer.apply(
                  session: session,
                  liveDb: live,
                  localSelfId: 'synthetic-new-device',
                ),
              );
              expect(await _digests(live), expected, reason: '恢复必须保留全部内容和关联');
              final preferences =
                  await (live.select(live.fitnessEntities)..where(
                        (row) => row.entityType.equals('fitness_preferences'),
                      ))
                      .getSingle();
              final image =
                  (jsonDecode(preferences.payload)['custom_exercises'] as List)
                          .single['image']
                      as String;
              expect(base64Decode(image), base64Decode(_image));
              await _checkImage(image);
              expect(
                await live.customSelect('PRAGMA foreign_key_check').get(),
                isEmpty,
              );
              expect(
                (await live.customSelect('PRAGMA integrity_check').getSingle())
                    .data
                    .values
                    .single,
                'ok',
              );
              final memo = (await MemoRepository(live).getEntries(_book)).first;
              await MemoRepository(live).saveEntry(
                MemoEntry(
                  id: _id(999999),
                  memoBookId: _book,
                  bookType: 'normal',
                  title: '恢复后离线新增',
                  bodyJson: memo.bodyJson,
                  createdAt: _start,
                  updatedAt: _start,
                ),
                await MemoRepository(live).target(_book),
              );
              expect(
                (await MemoRepository(live).getEntries(_book)).length,
                years * 365 + 1,
              );
              await MemoRepository(live).saveEntry(
                MemoEntry(
                  id: memo.id,
                  memoBookId: _book,
                  bookType: 'normal',
                  title: '恢复后离线修改',
                  bodyJson: memo.bodyJson,
                  createdAt: memo.createdAt,
                  updatedAt: _start,
                ),
                await MemoRepository(live).target(_book),
              );
              // 关闭并重新开库核对已提交的新建和修改，证明本地持久化边界。
              await live.close();
              live = SesameDatabase.withExecutor(
                NativeDatabase(
                  File('${root.path}/restored-$years-$repeat.sqlite'),
                ),
              );
              final reopened = await MemoRepository(live).getEntries(_book);
              expect(reopened.length, years * 365 + 1);
              expect(
                reopened.singleWhere((entry) => entry.id == memo.id).title,
                '恢复后离线修改',
              );
              expect(
                reopened.singleWhere((entry) => entry.id == _id(999999)).title,
                '恢复后离线新增',
              );
              reports.add({
                'years': years,
                'repeat': repeat + 1,
                'transactions': years * 1460,
                'memos': years * 365,
                'credentials': years * 24,
                'workouts': years * 156 + 2,
                'exercise_sets': years * 156 * 8 + 2,
                'backup_bytes': await file.length(),
                'sample_us': sample,
                'digests': expected,
                'integrity': 'ok',
                'offline_local_insert_modify_reopen': 'ok',
                'restored_image_decode': 'ok',
              });
              stdout.writeln('LONG_TERM_SAMPLE ${jsonEncode(reports.last)}');
            } finally {
              await live.close();
              await session.close();
            }
          }
        } finally {
          await source.close();
        }
      }
      final output = File('Temp/long_term_acceptance_results$suffix.json');
      await output.writeAsString(
        const JsonEncoder.withIndent('  ').convert({
          'mode':
              'Windows flutter test JIT; SQLite file-backed; no device/UI/network measurement',
          'scale':
              '1460 bills + 365 memos + 24 credential cards + 156 workouts per year; 10% long rich-text memos; 8 sets/workout; one embedded custom exercise PNG',
          'repetitions': _repeats,
          'samples': reports,
        }),
      );
    } catch (error, stack) {
      await File(
        'Temp/long_term_acceptance_error$suffix.log',
      ).writeAsString('$error\n$stack');
      stderr.writeln(
        '长期验收未完成，详细原因已写入 Temp/long_term_acceptance_error$suffix.log。',
      );
      rethrow;
    } finally {
      await root.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
