/// 备份加密链路测试。
///
/// - 单一 DEVICE_LOCAL key slot：DEK 由设备密钥（localSelfId 派生）包裹，
///   同一设备密钥解开 slot 即得 DEK；
/// - KDF 参数随 Envelope 携带，默认 64 MiB / 3 迭代 / 并行 1；
/// - payload 与 DEK 包裹 AEAD 均使用头部固定前缀 AAD——篡改
///   format_version/crypto_scheme/KDF 参数/salt → 密码学认证失败；
/// - 明文业务内容不出现在 Envelope 字节流中。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/domain/backup_envelope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const deviceKey = 'test-device-key';
  final plaintext = Uint8List.fromList(
    utf8.encode('{"ledgers":[{"name":"家庭账本"}]}密文不可见'),
  );

  test('冻结默认参数：Argon2id 64MiB / 3 迭代 / 并行 1', () {
    expect(BackupCrypto.defaultArgon2MemoryKiB, 64 * 1024);
    expect(BackupCrypto.defaultArgon2Iterations, 3);
    expect(BackupCrypto.defaultArgon2Parallelism, 1);
    expect(BackupKdfParams.defaults.memoryKib, 64 * 1024);
  });

  test('设备密钥往返：同一设备密钥加解密同一 payload', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    expect(envelope.keySlots, hasLength(1));
    expect(
      envelope.keySlots.single.type,
      BackupEnvelopeConstants.slotTypeDeviceLocal,
    );

    final decrypted = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      deviceKey: deviceKey,
    );
    expect(decrypted, plaintext);
  });

  test('错误设备密钥 → wrongKeyOrCorrupted', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    expect(
      () => BackupCrypto.decryptEnvelopePayload(
        envelope: envelope,
        deviceKey: 'wrong-device-key',
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongKeyOrCorrupted,
        ),
      ),
    );
  });

  test('篡改 payload 密文 → wrongKeyOrCorrupted（AEAD 认证失败）', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    final tampered = BackupEnvelope(
      formatVersion: envelope.formatVersion,
      cryptoScheme: envelope.cryptoScheme,
      kdfScheme: envelope.kdfScheme,
      kdfParams: envelope.kdfParams,
      salt: envelope.salt,
      payloadNonce: envelope.payloadNonce,
      payloadTag: envelope.payloadTag,
      keySlots: envelope.keySlots,
      encryptedPayload: Uint8List.fromList(
        List.generate(
          envelope.encryptedPayload.length,
          (i) => envelope.encryptedPayload[i] ^ (i == 5 ? 0xff : 0),
        ),
      ),
    );
    expect(
      () => BackupCrypto.decryptEnvelopePayload(
        envelope: tampered,
        deviceKey: deviceKey,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongKeyOrCorrupted,
        ),
      ),
    );
  });

  test('篡改头部 KDF 参数 → 密码学认证失败而非解析失败（AAD）', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    final tampered = BackupEnvelope(
      formatVersion: envelope.formatVersion,
      cryptoScheme: envelope.cryptoScheme,
      kdfScheme: envelope.kdfScheme,
      kdfParams: BackupKdfParams(
        memoryKib: envelope.kdfParams.memoryKib,
        iterations: envelope.kdfParams.iterations + 1,
        parallelism: envelope.kdfParams.parallelism,
      ),
      salt: envelope.salt,
      payloadNonce: envelope.payloadNonce,
      payloadTag: envelope.payloadTag,
      keySlots: envelope.keySlots,
      encryptedPayload: envelope.encryptedPayload,
    );
    expect(
      () => BackupCrypto.decryptEnvelopePayload(
        envelope: tampered,
        deviceKey: deviceKey,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongKeyOrCorrupted,
        ),
      ),
    );
  });

  test('篡改包裹的 DEK slot → wrongKeyOrCorrupted', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    final tamperedSlot = BackupKeySlot(
      type: envelope.keySlots.single.type,
      nonce: envelope.keySlots.single.nonce,
      ciphertext: Uint8List.fromList(envelope.keySlots.single.ciphertext)
        ..[0] ^= 0x01,
      tag: envelope.keySlots.single.tag,
    );
    final tampered = BackupEnvelope(
      formatVersion: envelope.formatVersion,
      cryptoScheme: envelope.cryptoScheme,
      kdfScheme: envelope.kdfScheme,
      kdfParams: envelope.kdfParams,
      salt: envelope.salt,
      payloadNonce: envelope.payloadNonce,
      payloadTag: envelope.payloadTag,
      keySlots: [tamperedSlot],
      encryptedPayload: envelope.encryptedPayload,
    );
    expect(
      () => BackupCrypto.decryptEnvelopePayload(
        envelope: tampered,
        deviceKey: deviceKey,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongKeyOrCorrupted,
        ),
      ),
    );
  });

  test('明文业务内容不出现在 Envelope 字节流中', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      deviceKey: deviceKey,
    );
    final bytes = BackupEnvelopeCodec.encode(envelope);
    final asString = latin1.decode(bytes);
    expect(asString.contains('家庭账本'), isFalse);
    expect(asString.contains('ledgers'), isFalse);
  });
}
