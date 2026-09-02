/// 备份加密链路测试。
///
/// - Multi-Key-Slot：同一 DEK 分别被 密码 / 恢复词 / 设备密钥 包裹，
///   任一凭据解开对应 slot 即得同一 DEK——忘记密码可凭恢复词恢复；
/// - KDF 参数随 Envelope 携带，默认 64 MiB / 3 迭代 / 并行 1；
/// - payload 与 DEK 包裹 AEAD 均使用头部固定前缀 AAD——篡改
///   format_version/crypto_scheme/KDF 参数/salt → 密码学认证失败；
/// - 恢复词 16 组 × 256 词表 = 128 bit 熵；
/// - 改密码不重加密 payload：rewrapDek 只重包 slot；
/// - 明文业务内容不出现在 Envelope 字节流中。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/domain/backup_envelope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const password = 'correct horse battery staple';
  final plaintext = Uint8List.fromList(
    utf8.encode('{"ledgers":[{"name":"家庭账本"}]}密文不可见'),
  );

  test('冻结默认参数：Argon2id 64MiB / 3 迭代 / 并行 1', () {
    expect(BackupCrypto.defaultArgon2MemoryKiB, 64 * 1024);
    expect(BackupCrypto.defaultArgon2Iterations, 3);
    expect(BackupCrypto.defaultArgon2Parallelism, 1);
    expect(BackupKdfParams.defaults.memoryKib, 64 * 1024);
  });

  test('Multi-Key-Slot：密码/恢复词/设备密钥各自可解开同一 DEK', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
      recoveryKey:
          'alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike november oscar papa',
      deviceKey: 'device-key-1',
    );
    expect(envelope.keySlots, hasLength(3));
    expect(envelope.keySlots.map((s) => s.type).toSet(), {
      BackupEnvelopeConstants.slotTypePassword,
      BackupEnvelopeConstants.slotTypeRecovery,
      BackupEnvelopeConstants.slotTypeDeviceLocal,
    });

    // 密码可解
    final viaPassword = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      password: password,
    );
    expect(viaPassword, plaintext);
    // 恢复词可解（忘记密码场景）
    final viaRecovery = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      recoveryKey:
          'alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike november oscar papa',
    );
    expect(viaRecovery, plaintext);
    // 设备密钥可解（本机兜底）
    final viaDevice = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      deviceKey: 'device-key-1',
    );
    expect(viaDevice, plaintext);
  });

  test('错误凭据 → wrongPasswordOrCorrupted', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
      recoveryKey:
          'one two three four five six seven eight nine ten eleven twelve',
    );
    expect(
      () => BackupCrypto.decryptEnvelopePayload(
        envelope: envelope,
        password: 'wrong-password',
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongPasswordOrCorrupted,
        ),
      ),
    );
  });

  test('篡改 payload 密文 → wrongPasswordOrCorrupted（AEAD 认证失败）', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
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
        password: password,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongPasswordOrCorrupted,
        ),
      ),
    );
  });

  test('篡改头部 KDF 参数/salt → 密码学认证失败而非解析失败（AAD）', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
    );
    // 篡改 kdf_iterations（头部偏移 28..32 中的字节）——AAD 参与认证，必须失败
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
        password: password,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongPasswordOrCorrupted,
        ),
      ),
    );
  });

  test('篡改包裹的 DEK slot → wrongPasswordOrCorrupted', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
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
        password: password,
      ),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.wrongPasswordOrCorrupted,
        ),
      ),
    );
  });

  test('明文业务内容不出现在 Envelope 字节流中', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: password,
    );
    final bytes = BackupEnvelopeCodec.encode(envelope);
    final asString = latin1.decode(bytes);
    expect(asString.contains('家庭账本'), isFalse);
    expect(asString.contains('ledgers'), isFalse);
  });

  test('rewrapDek：改密码只重包 slot，payload 一字节不动', () async {
    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      password: 'old-password',
      recoveryKey: 'old recovery key words here twelve total',
    );
    final rewritten = await BackupCrypto.rewrapDek(
      envelope: envelope,
      oldPassword: 'old-password',
      newPassword: 'new-password',
    );
    // payload 不变
    expect(rewritten.encryptedPayload, envelope.encryptedPayload);
    expect(rewritten.payloadNonce, envelope.payloadNonce);
    // 旧密码失效、新密码可解；恢复词仍可解（未替换的 slot 保留）
    await expectLater(
      BackupCrypto.decryptEnvelopePayload(
        envelope: rewritten,
        password: 'old-password',
      ),
      throwsA(isA<BackupFormatException>()),
    );
    final viaNew = await BackupCrypto.decryptEnvelopePayload(
      envelope: rewritten,
      password: 'new-password',
    );
    expect(viaNew, plaintext);
    final viaRecovery = await BackupCrypto.decryptEnvelopePayload(
      envelope: rewritten,
      recoveryKey: 'old recovery key words here twelve total',
    );
    expect(viaRecovery, plaintext);
  });

  test('恢复词：16 组（128 bit 熵），哈希验证，可作凭据', () async {
    final words = BackupCrypto.generateRecoveryKeyWords();
    expect(words, hasLength(16));
    expect(words.toSet().length, 16, reason: '恢复词不得重复');
    final key = words.join(' ');
    final hash = BackupCrypto.hashRecoveryKey(key);
    expect(hash, isNot(contains(key)));
    expect(BackupCrypto.verifyRecoveryKey(key, hash), isTrue);
    expect(BackupCrypto.verifyRecoveryKey('another key words', hash), isFalse);

    final envelope = await BackupCrypto.createEnvelope(
      plaintextPayload: plaintext,
      recoveryKey: key,
    );
    final decrypted = await BackupCrypto.decryptEnvelopePayload(
      envelope: envelope,
      recoveryKey: key,
    );
    expect(decrypted, plaintext);
  });
}
