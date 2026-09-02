/// BackupEnvelope / BackupManifest 生成与解析测试。
///
/// - Envelope 头部：magic / format_version / crypto_scheme / KDF 参数 /
///   salt / payload nonce+tag / key_slots（Multi-Key-Slot，每 slot
///   type+nonce+ciphertext+tag 共 61B）/ encrypted_payload，逐字节冻结布局；
/// - AAD = 头部固定前缀（magic..salt，53B）；
/// - format_version 与 db_schema_version 分离：Manifest 双写 format_version；
/// - Manifest 含统计字段（pending/open/last_sync_at，无 last_server_revision）；
/// - 旧格式/损坏/版本不支持一律拒绝（打开路径）。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/domain/backup_envelope.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

void main() {
  group('BackupEnvelopeCodec', () {
    BackupEnvelope baseEnvelope() => BackupEnvelope(
      formatVersion: BackupEnvelopeConstants.formatVersion,
      cryptoScheme: BackupEnvelopeConstants.cryptoSchemeAes256Gcm,
      kdfScheme: BackupEnvelopeConstants.kdfSchemeArgon2id,
      kdfParams: BackupKdfParams.defaults,
      salt: Uint8List.fromList(List.generate(16, (i) => i)),
      payloadNonce: Uint8List.fromList(List.generate(12, (i) => 0x10 + i)),
      payloadTag: Uint8List.fromList(List.generate(16, (i) => 0x20 + i)),
      keySlots: [
        BackupKeySlot(
          type: BackupEnvelopeConstants.slotTypePassword,
          nonce: Uint8List.fromList(List.generate(12, (i) => 0x30 + i)),
          ciphertext: Uint8List.fromList(List.generate(32, (i) => 0x40 + i)),
          tag: Uint8List.fromList(List.generate(16, (i) => 0x50 + i)),
        ),
        BackupKeySlot(
          type: BackupEnvelopeConstants.slotTypeRecovery,
          nonce: Uint8List.fromList(List.generate(12, (i) => 0x60 + i)),
          ciphertext: Uint8List.fromList(List.generate(32, (i) => 0x70 + i)),
          tag: Uint8List.fromList(List.generate(16, (i) => 0x80 + i)),
        ),
      ],
      encryptedPayload: Uint8List.fromList([1, 2, 3, 4, 5]),
    );

    test('编码→解码往返保持全部字段（含 KDF 参数与 key slots）', () {
      final envelope = baseEnvelope();
      final bytes = BackupEnvelopeCodec.encode(envelope);
      final decoded = BackupEnvelopeCodec.decode(bytes);

      expect(decoded.formatVersion, BackupEnvelopeConstants.formatVersion);
      expect(
        decoded.cryptoScheme,
        BackupEnvelopeConstants.cryptoSchemeAes256Gcm,
      );
      expect(decoded.kdfScheme, BackupEnvelopeConstants.kdfSchemeArgon2id);
      expect(decoded.kdfParams.memoryKib, 64 * 1024);
      expect(decoded.kdfParams.iterations, 3);
      expect(decoded.kdfParams.parallelism, 1);
      expect(decoded.salt, envelope.salt);
      expect(decoded.payloadNonce, envelope.payloadNonce);
      expect(decoded.payloadTag, envelope.payloadTag);
      expect(decoded.keySlots, hasLength(2));
      expect(
        decoded.keySlots[0].type,
        BackupEnvelopeConstants.slotTypePassword,
      );
      expect(decoded.keySlots[0].ciphertext, envelope.keySlots[0].ciphertext);
      expect(decoded.keySlots[0].tag, envelope.keySlots[0].tag);
      expect(
        decoded.keySlots[1].type,
        BackupEnvelopeConstants.slotTypeRecovery,
      );
      expect(decoded.encryptedPayload, envelope.encryptedPayload);
      // AAD = 头部固定前缀
      expect(decoded.aad.length, BackupEnvelopeConstants.aadPrefixLength);
      expect(decoded.aad, envelope.aad);
    });

    test('头部长度冻结：53 + 12 + 16 + 1 + 61×2 = 204，payload 追加其后', () {
      final envelope = baseEnvelope();
      final bytes = BackupEnvelopeCodec.encode(envelope);
      expect(bytes.length, 204 + envelope.encryptedPayload.length);
    });

    test('magic 不匹配（旧格式/非备份文件）→ corrupt', () {
      final legacy = Uint8List.fromList(utf8.encode('SQLite format 3\x00...'));
      expect(
        () => BackupEnvelopeCodec.decode(legacy),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
    });

    test('format_version 超出支持范围 → unsupportedVersion', () {
      final bytes = BackupEnvelopeCodec.encode(baseEnvelope());
      final tampered = Uint8List.fromList(bytes);
      tampered[19] = 99; // format_version 首字节（magic 19B 之后，BE）
      expect(
        () => BackupEnvelopeCodec.decode(tampered),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.unsupportedVersion,
          ),
        ),
      );
    });

    test('crypto_scheme 未实现（0x02 XChaCha）→ unsupportedScheme', () {
      final bytes = BackupEnvelopeCodec.encode(baseEnvelope());
      final tampered = Uint8List.fromList(bytes);
      tampered[23] = 0x02; // crypto_scheme（magic19+version4+kdf_scheme1 之后）
      expect(
        () => BackupEnvelopeCodec.decode(tampered),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.unsupportedScheme,
          ),
        ),
      );
    });

    test('KDF 参数非法（memory < 1024KiB）→ corrupt', () {
      final bytes = BackupEnvelopeCodec.encode(baseEnvelope());
      final tampered = Uint8List.fromList(bytes);
      // kdf_memory_kib = u32 BE，偏移 25-28（magic19+version4+scheme1+kdf_scheme1）
      tampered[25] = 0;
      tampered[26] = 0;
      tampered[27] = 1; // 0x00000100 = 256 KiB < 1024 → corrupt
      expect(
        () => BackupEnvelopeCodec.decode(tampered),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
    });

    test('截断文件 → corrupt', () {
      final bytes = BackupEnvelopeCodec.encode(baseEnvelope());
      final truncated = Uint8List.fromList(bytes.sublist(0, 100));
      expect(
        () => BackupEnvelopeCodec.decode(truncated),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
    });

    test('未知 slot 类型 → corrupt', () {
      final bytes = BackupEnvelopeCodec.encode(baseEnvelope());
      final tampered = Uint8List.fromList(bytes);
      // slot_count 在偏移 53+12+16=81；第一个 slot type 在 82
      tampered[82] = 0x77;
      expect(
        () => BackupEnvelopeCodec.decode(tampered),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
    });
  });

  group('BackupManifest', () {
    test('JSON 往返保持全部字段（含统计字段，无 last_server_revision）', () {
      final manifest = BackupManifest(
        formatVersion: 1,
        dbSchemaVersion: 1,
        createdAt: DateTime.utc(2026, 8, 21, 2, 13),
        deviceId: 'device-1',
        appVersion: '1.0.0+1',
        ledgers: [
          ManifestLedger(
            ledgerBackupId: 'bl-1',
            name: '家庭账本',
            storageOrigin: LedgerStorageOrigin.cloud,
            originalLocalLedgerId: null,
            cloudProvider: 'sesame_notes',
            originalCloudLedgerId: 'cl-1',
            originalAccountId: 'acc-1',
            ownerType: 'OWNER',
            pendingMutationCount: 3,
            openConflictCount: 1,
            lastSyncAt: DateTime.utc(2026, 8, 21, 1, 0),
          ),
          ManifestLedger(
            ledgerBackupId: 'bl-2',
            name: '私人账本',
            storageOrigin: LedgerStorageOrigin.local,
            originalLocalLedgerId: 'll-1',
            cloudProvider: null,
            originalCloudLedgerId: null,
            originalAccountId: null,
            ownerType: 'OWNER',
            pendingMutationCount: 0,
            openConflictCount: 0,
            lastSyncAt: null,
          ),
        ],
        accounts: [ManifestAccount(accountId: 'acc-1', accountName: 'alice')],
      );

      final json = manifest.toJson();
      final decoded = BackupManifest.fromJson(json);

      expect(decoded.formatVersion, 1);
      expect(decoded.dbSchemaVersion, 1);
      expect(decoded.ledgers, hasLength(2));
      expect(decoded.ledgers[0].name, '家庭账本');
      expect(decoded.ledgers[0].pendingMutationCount, 3);
      expect(decoded.ledgers[0].openConflictCount, 1);
      expect(decoded.ledgers[0].lastSyncAt, DateTime.utc(2026, 8, 21, 1, 0));
      expect(decoded.ledgers[1].lastSyncAt, isNull);
      expect(decoded.accounts[0].accountName, 'alice');
      // 不设 last_server_revision
      expect(json.containsKey('last_server_revision'), isFalse);
    });

    test('缺必填字段 → invalidManifest', () {
      final json = <String, dynamic>{
        'format_version': 1,
        'created_at': '2026-08-21T02:13:00.000Z',
        'device_id': 'd',
        'app_version': 'v',
        'ledgers': <Object>[],
        'accounts': <Object>[],
      };
      expect(
        () => BackupManifest.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.invalidManifest,
          ),
        ),
      );
    });

    test('created_at 非法时间 → invalidManifest', () {
      final json = <String, dynamic>{
        'format_version': 1,
        'db_schema_version': 1,
        'created_at': 'not-a-date',
        'device_id': 'd',
        'app_version': 'v',
        'ledgers': <Object>[],
        'accounts': <Object>[],
      };
      expect(
        () => BackupManifest.fromJson(json),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.invalidManifest,
          ),
        ),
      );
    });
  });

  group('BackupPayloadCodec', () {
    test('Manifest JSON + SQLite 体分帧往返', () {
      final manifestBytes = Uint8List.fromList(utf8.encode('{"a":1}'));
      final sqliteBytes = Uint8List.fromList(
        List.generate(100, (i) => i % 251),
      );

      final framed = BackupPayloadCodec.encode(manifestBytes, sqliteBytes);
      final decoded = BackupPayloadCodec.decode(framed);

      expect(utf8.decode(decoded.manifestJson), '{"a":1}');
      expect(decoded.sqliteBytes, sqliteBytes);
    });

    test('长度字段损坏/截断 → corrupt', () {
      final framed = BackupPayloadCodec.encode(
        Uint8List.fromList([1]),
        Uint8List.fromList([2, 3]),
      );
      final truncated = Uint8List.fromList(framed.sublist(0, 4));
      expect(
        () => BackupPayloadCodec.decode(truncated),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupOpenError.corrupt,
          ),
        ),
      );
    });
  });
}
