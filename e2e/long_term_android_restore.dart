import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

/// 在手机测试包沙箱内执行一次完整备份和干净库恢复，原产品库保持打开且不被替换。
Future<void> runAndroidRestoreProbe(
  SesameDatabase source,
  File sourceFile,
  Directory ownerDirectory,
  String localSelfId,
  void Function(Map<String, Object?>) emit,
) async {
  final directory = await ownerDirectory.createTemp('restore-');
  final restoreFile = File(p.join(directory.path, 'new-device.sqlite'));
  final target = SesameDatabase.withExecutor(
    NativeDatabase.createInBackground(restoreFile),
  );
  RecoverySession? session;
  final timings = <String, int>{};
  try {
    final expected = await _fingerprints(source);
    final backup = LocalBackupService(
      databaseFile: sourceFile,
      backupDir: Directory(p.join(directory.path, 'backups')),
    );
    final timer = Stopwatch()..start();
    final file = await backup.createBackup(
      db: source,
      trigger: BackupTrigger.automatic,
    );
    timings['backup_us'] = timer.elapsedMicroseconds;
    timer
      ..reset()
      ..start();
    final importer = BackupImportService(tempDirOverride: directory);
    session = await importer.openBackup(backupFile: file);
    timings['preview_us'] = timer.elapsedMicroseconds;
    for (final item in await importer.listRecoveryItems(session)) {
      session.decisions[item.ledgerBackupId] = RecoveryDecision.restoreLocal;
    }
    for (final book in session.manifest.memoBooks) {
      session.memoBookDecisions[book.id] = RecoveryDecision.restoreLocal;
    }
    session.memoTargetSnapshots.addAll(
      await importer.captureMemoTargets(target, session.memoBookDecisions.keys),
    );
    for (final space in session.manifest.fitnessSpaces) {
      session.fitnessSpaceDecisions[space.id] = RecoveryDecision.restoreLocal;
      session.fitnessTargetSnapshots[space.id] =
          await FitnessDataTransfer.fingerprint(target, space.id);
    }
    timer
      ..reset()
      ..start();
    await importer.apply(
      session: session,
      liveDb: target,
      localSelfId: 'qa-new-device-$localSelfId',
    );
    timings['restore_us'] = timer.elapsedMicroseconds;
    timer.stop();
    final restored = await _fingerprints(target);
    if (jsonEncode(expected) != jsonEncode(restored)) {
      throw StateError('手机恢复后业务内容或关系摘要不一致');
    }
    if (jsonEncode(expected) != jsonEncode(await _fingerprints(source))) {
      throw StateError('手机恢复验收期间源数据发生变化，请保持应用前台且不要编辑');
    }
    if ((await target.customSelect('PRAGMA foreign_key_check').get())
            .isNotEmpty ||
        (await target.customSelect('PRAGMA integrity_check').getSingle())
                .data
                .values
                .single !=
            'ok') {
      throw StateError('手机恢复数据库未通过SQLite完整性检查');
    }
    var images = 0;
    for (final row
        in await target
            .customSelect(
              "SELECT payload FROM fitness_entities WHERE entity_type='fitness_preferences'",
            )
            .get()) {
      final customs =
          (jsonDecode(row.read<String>('payload')) as Map)['custom_exercises']
              as List;
      for (final exercise in customs) {
        final encoded = (exercise as Map)['image'];
        if (encoded is! String || encoded.isEmpty) continue;
        ui.Codec? codec;
        ui.Image? image;
        try {
          codec = await ui.instantiateImageCodec(base64Decode(encoded));
          image = (await codec.getNextFrame()).image;
          if (image.width < 1 || image.height < 1) throw StateError('恢复图片无法显示');
          images++;
        } finally {
          image?.dispose();
          codec?.dispose();
        }
      }
    }
    if (images == 0) throw StateError('手机恢复没有包含实际支持的动作图片');
    emit({
      'type': 'physical_storage_restore',
      'samples': 1,
      'timings_us': timings,
      'backup_bytes': await file.length(),
      'semantic_sha256': expected,
      'integrity': 'ok',
      'foreign_keys': 'ok',
      'decoded_images': images,
      'source_database_untouched': true,
      'target': restoreFile.path,
      'scope':
          'same Android physical device, isolated new SQLite file; not a second-phone migration',
    });
  } catch (error, stack) {
    emit({
      'type': 'physical_restore_error',
      'error': safeErrorSummary(error),
      'stack': '$stack',
    });
    rethrow;
  } finally {
    await session?.close();
    await target.close();
    // 保留本任务拥有的备份和恢复库供人工复核，不覆盖主应用文件。
  }
}

/// 对完整夹具业务记录计算稳定摘要；恢复会重建账单和成员身份，按映射后的语义核对。
Future<Map<String, String>> _fingerprints(SesameDatabase db) async {
  try {
    final queries = {
      'transactions':
          'SELECT t.ledger_id,t.tx_type,t.amount,t.currency_code,t.native_amount,t.happened_at,t.note,t.created_at,t.deleted_at,t.aa_mode,t.version,t.last_edited_at,m.display_name AS payer,m.member_type AS payer_type,c.name AS category FROM transactions t LEFT JOIN ledger_members m ON t.payer_member_id=m.id LEFT JOIN categories c ON t.category_id=c.id ORDER BY t.happened_at,t.note',
      'memos':
          'SELECT id,memo_book_id,book_type,title,body_format,body,order_key,created_at,updated_at,deleted_at,source_entry_id,source_conflict_id FROM memo_entries ORDER BY id',
      'fitness':
          'SELECT id,fitness_space_id,entity_type,payload,created_at,updated_at,deleted_at FROM fitness_entities ORDER BY id',
      'ledgers':
          'SELECT id,name,currency,storage_mode,month_start_day FROM ledgers ORDER BY id',
      'memo_books':
          'SELECT id,name,type,storage_mode FROM memo_books ORDER BY id',
      'fitness_spaces':
          'SELECT id,name,storage_mode FROM fitness_spaces ORDER BY id',
    };
    final result = <String, String>{};
    for (final query in queries.entries) {
      final rows = await db.customSelect(query.value).get();
      final values = rows
          .map(
            (row) => {
              for (final column in row.data.entries)
                column.key:
                    (column.key == 'body' || column.key == 'payload') &&
                        column.value is String
                    ? jsonDecode(column.value as String)
                    : column.value,
            },
          )
          .toList();
      result[query.key] = sha256
          .convert(utf8.encode(jsonEncode(_canonical(values))))
          .toString();
    }
    return result;
  } catch (error, stack) {
    logger.error(
      'AndroidLongTermProbe',
      '业务内容校验失败',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}

/// 排序对象字段但保留列表顺序，避免JSON键书写顺序影响语义摘要。
Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) return value.map(_canonical).toList();
  return value;
}
