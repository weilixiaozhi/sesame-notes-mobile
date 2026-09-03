/// 备份加密链路：Argon2id KDF + AES-256-GCM Envelope。
///
/// - KDF：Argon2id，**参数随 Envelope 携带**，输入 = 设备密钥 + 文件内 salt；
/// - 单一 DEVICE_LOCAL key slot：同一 DEK 由设备密钥（localSelfId 派生）的
///   KEK 包裹，本机备份/恢复均走该 slot；
/// - payload 与 DEK 包裹的 AEAD 均使用头部固定前缀作为 AAD；
/// - 失败语义：设备密钥无法解开 slot（密钥不匹配、数据损坏）统一归类为
///   wrongKeyOrCorrupted，调用方据此拒绝恢复且保证 live DB 0 mutation。
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';

import 'backup_envelope.dart';

/// 备份凭据集合（单一设备密钥）。
class BackupSecrets {
  const BackupSecrets({this.deviceKey});

  /// 设备密钥（localSelfId 派生）。
  final String? deviceKey;

  /// 是否已提供设备密钥。
  bool get hasAny => deviceKey != null;
}

/// 备份加密服务（无状态纯函数集合，测试友好）。
class BackupCrypto {
  BackupCrypto._();

  /// Argon2id 默认内存参数（KiB）：64 MiB（首版冻结；随文件携带，未来可调）。
  static const int defaultArgon2MemoryKiB = 64 * 1024;

  /// Argon2id 默认迭代次数：3。
  static const int defaultArgon2Iterations = 3;

  /// Argon2id 默认并行度：1。
  static const int defaultArgon2Parallelism = 1;

  static final _random = Random.secure();
  static final _aesGcm = AesGcm.with256bits();

  /// 按文件内参数派生 KEK：Argon2id(secret, salt) → 256-bit。
  ///
  /// 参数从 [kdfParams] 读取（旧备份按自身参数派生，未来调参不破坏旧文件）。
  static Future<SecretKey> _deriveKek(
    String secret,
    Uint8List salt,
    BackupKdfParams kdfParams,
  ) async {
    final argon2id = Argon2id(
      memory: kdfParams.memoryKib,
      iterations: kdfParams.iterations,
      parallelism: kdfParams.parallelism,
      hashLength: BackupEnvelopeConstants.dekLength,
    );
    return argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(secret)),
      nonce: salt,
    );
  }

  /// 用 KEK 包裹 DEK 并构造 key slot（AAD = 头部固定前缀）。
  static Future<BackupKeySlot> _wrapDek(
    SecretKey kek,
    Uint8List dek,
    int slotType,
    Uint8List aad,
  ) async {
    final nonce = _randomNonce();
    final box = await _aesGcm.encrypt(
      dek,
      secretKey: kek,
      nonce: nonce,
      aad: aad,
    );
    return BackupKeySlot(
      type: slotType,
      nonce: Uint8List.fromList(box.nonce),
      ciphertext: Uint8List.fromList(box.cipherText),
      tag: Uint8List.fromList(box.mac.bytes),
    );
  }

  /// 尝试解开指定 slot；密钥不匹配（凭据错误/数据损坏）返回 null。
  static Future<Uint8List?> _unwrapSlot(
    BackupKeySlot slot,
    SecretKey kek,
    Uint8List aad,
  ) async {
    try {
      final box = SecretBox(
        slot.ciphertext,
        nonce: slot.nonce,
        mac: Mac(slot.tag),
      );
      final dek = await _aesGcm.decrypt(box, secretKey: kek, aad: aad);
      return Uint8List.fromList(dek);
    } catch (_) {
      return null;
    }
  }

  /// 生成随机 256-bit DEK。
  static Future<Uint8List> generateDek() async {
    return Uint8List.fromList(
      List.generate(
        BackupEnvelopeConstants.dekLength,
        (_) => _random.nextInt(256),
      ),
    );
  }

  /// 创建设备密钥保护的完整 Envelope：随机盐 + 随机 DEK + DEVICE_LOCAL
  /// key slot + payload 加密。
  ///
  /// [kdfParams] 缺省为冻结默认参数（64 MiB/3/1），并写入文件头。
  static Future<BackupEnvelope> createEnvelope({
    required Uint8List plaintextPayload,
    required String deviceKey,
    BackupKdfParams? kdfParams,
  }) async {
    final params = kdfParams ?? BackupKdfParams.defaults;
    final salt = _randomSalt();
    final dek = await generateDek();
    final dekKey = SecretKey(dek);

    // AAD = 头部固定前缀：payload 与 DEK 包裹共用同一 AAD，
    // 必须先于两处加密构建（payload 加密必须携带 AAD）。
    final payloadNonce = _randomNonce();
    final aad = _buildAad(
      formatVersion: BackupEnvelopeConstants.formatVersion,
      cryptoScheme: BackupEnvelopeConstants.cryptoSchemeAes256Gcm,
      kdfParams: params,
      salt: salt,
    );
    final box = await _aesGcm.encrypt(
      plaintextPayload,
      secretKey: dekKey,
      nonce: payloadNonce,
      aad: aad,
    );

    final kek = await _deriveKek(deviceKey, salt, params);
    final slot = await _wrapDek(
      kek,
      dek,
      BackupEnvelopeConstants.slotTypeDeviceLocal,
      aad,
    );

    return BackupEnvelope(
      formatVersion: BackupEnvelopeConstants.formatVersion,
      cryptoScheme: BackupEnvelopeConstants.cryptoSchemeAes256Gcm,
      kdfScheme: BackupEnvelopeConstants.kdfSchemeArgon2id,
      kdfParams: params,
      salt: salt,
      payloadNonce: Uint8List.fromList(box.nonce),
      payloadTag: Uint8List.fromList(box.mac.bytes),
      keySlots: [slot],
      encryptedPayload: Uint8List.fromList(box.cipherText),
    );
  }

  /// 用设备密钥解密 Envelope 的 payload。
  ///
  /// 匹配规则：设备密钥 → DEVICE_LOCAL slot；解不开 → wrongKeyOrCorrupted。
  /// 返回分帧明文（调用方用 BackupPayloadCodec.decode 解出 Manifest + SQLite 体）。
  static Future<Uint8List> decryptEnvelopePayload({
    required BackupEnvelope envelope,
    required String deviceKey,
  }) async {
    final kek = await _deriveKek(deviceKey, envelope.salt, envelope.kdfParams);
    final aad = envelope.aad;
    Uint8List? dek;
    for (final slot in envelope.keySlots) {
      if (slot.type != BackupEnvelopeConstants.slotTypeDeviceLocal) continue;
      dek = await _unwrapSlot(slot, kek, aad);
      if (dek != null) break;
    }
    if (dek == null) {
      throw const BackupFormatException(
        BackupOpenError.wrongKeyOrCorrupted,
        '设备密钥无法解开备份（密钥不匹配或文件损坏）',
      );
    }
    try {
      final box = SecretBox(
        envelope.encryptedPayload,
        nonce: envelope.payloadNonce,
        mac: Mac(envelope.payloadTag),
      );
      final plaintext = await _aesGcm.decrypt(
        box,
        secretKey: SecretKey(dek),
        aad: aad,
      );
      return Uint8List.fromList(plaintext);
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.wrongKeyOrCorrupted,
        'payload 解密失败：密钥错误或文件损坏',
      );
    }
  }

  /// 设备绑定密钥：localSelfId 派生（DEVICE_LOCAL slot 的 KDF 输入）。
  static String deviceKeyFromLocalSelfId(String localSelfId) => sha256
      .convert(utf8.encode('sesame-notes-backup:$localSelfId'))
      .toString();

  /// 构建头部固定前缀（AAD）。
  static Uint8List _buildAad({
    required int formatVersion,
    required int cryptoScheme,
    required BackupKdfParams kdfParams,
    required Uint8List salt,
  }) {
    final out = ByteData(BackupEnvelopeConstants.aadPrefixLength);
    var offset = 0;
    for (final b in BackupEnvelopeConstants.magic) {
      out.setUint8(offset++, b);
    }
    out.setUint32(offset, formatVersion);
    offset += 4;
    out.setUint8(offset++, cryptoScheme);
    out.setUint8(offset++, BackupEnvelopeConstants.kdfSchemeArgon2id);
    out.setUint32(offset, kdfParams.memoryKib);
    offset += 4;
    out.setUint32(offset, kdfParams.iterations);
    offset += 4;
    out.setUint32(offset, kdfParams.parallelism);
    offset += 4;
    out.buffer.asUint8List().setRange(offset, offset + salt.length, salt);
    return out.buffer.asUint8List();
  }

  static Uint8List _randomSalt() => Uint8List.fromList(
    List.generate(
      BackupEnvelopeConstants.saltLength,
      (_) => _random.nextInt(256),
    ),
  );

  static Uint8List _randomNonce() => Uint8List.fromList(
    List.generate(
      BackupEnvelopeConstants.nonceLength,
      (_) => _random.nextInt(256),
    ),
  );
}
