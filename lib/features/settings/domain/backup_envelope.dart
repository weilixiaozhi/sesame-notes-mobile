/// 备份信封（BackupEnvelope）二进制编解码。
///
/// magic(19B) + format_version(u32) + crypto_scheme(u8) + kdf_scheme(u8) +
/// kdf_memory_kib(u32) + kdf_iterations(u32) + kdf_parallelism(u32) + salt(16B) +
/// payload_nonce(12B) + payload_tag(16B) + key_slot_count(u8) +
/// key_slots[]（每 slot 61B：type(1) + nonce(12) + ciphertext(32) + tag(16)）
/// + encrypted_payload。
///
/// - Multi-Key-Slot：同一 DEK 被密码/恢复词/设备密钥分别包裹；
/// - KDF 参数随文件携带，派生 KEK 时读取文件内参数；
/// - 头部固定前缀（magic..salt）作为 payload 与 DEK 包裹 AEAD 的 AAD。
library;

import 'dart:typed_data';

/// Envelope 打开失败的分类原因；每种原因对应独立用户文案。
enum BackupOpenError {
  /// 文件损坏 / 非备份文件 / 截断
  corrupt,

  /// format_version 不在应用支持范围
  unsupportedVersion,

  /// crypto_scheme 未实现（保留方案，本期不落地）
  unsupportedScheme,

  /// Manifest 校验失败（字段缺失/类型错误）
  invalidManifest,

  /// 提供的凭据均无法解开任何 key slot（密码错误/恢复词错误/文件损坏）
  wrongPasswordOrCorrupted,

  /// 备份 schema 旧于当前应用
  schemaTooOld,

  /// 备份 schema 新于当前应用（提示升级 App）
  schemaTooNew,
}

/// 备份格式异常：携带分类原因，UI 据此展示对应文案。
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason, this.message);

  /// 失败分类（决定用户提示与后续策略）
  final BackupOpenError reason;

  /// 人类可读描述（记日志用，不直接向用户展示原始信息）
  final String message;

  @override
  String toString() => 'BackupFormatException($reason): $message';
}

/// 冻结的 Envelope 布局常量。
class BackupEnvelopeConstants {
  BackupEnvelopeConstants._();

  /// 魔数：ASCII "SESAME-NOTES-BACKUP"（19 字节，不含结尾 NUL）。
  static const List<int> magic = [
    0x53, 0x45, 0x53, 0x41, 0x4d, 0x45, 0x2d, // SESAME-
    0x4e, 0x4f, 0x54, 0x45, 0x53, 0x2d, // NOTES-
    0x42, 0x41, 0x43, 0x4b, 0x55, 0x50, // BACKUP
  ];

  /// 当前备份格式版本（首版 = 1；变更视为格式升级）。
  static const int formatVersion = 1;

  /// 本应用支持的格式版本范围 [min, max]：版本号是数据，范围比较是通用逻辑。
  static const int minSupportedFormatVersion = 1;
  static const int maxSupportedFormatVersion = 1;

  /// 加密方案：0x01 = AES-256-GCM（落地）；0x02 = XChaCha20-Poly1305（保留）。
  static const int cryptoSchemeAes256Gcm = 0x01;
  static const int cryptoSchemeXChaCha20Poly1305 = 0x02;

  /// KDF 方案：0x01 = Argon2id。
  static const int kdfSchemeArgon2id = 0x01;

  /// key slot 类型（Multi-Key-Slot）。
  static const int slotTypePassword = 0x01;

  /// 恢复词 slot。
  static const int slotTypeRecovery = 0x02;

  /// 设备密钥 slot（本机自动备份无密码时兜底，可省略）。
  static const int slotTypeDeviceLocal = 0x03;

  /// 支持的全部 slot 类型（编解码校验用）。
  static const Set<int> supportedSlotTypes = {
    slotTypePassword,
    slotTypeRecovery,
    slotTypeDeviceLocal,
  };

  /// KDF 盐长度（Argon2id）。
  static const int saltLength = 16;

  /// GCM nonce 长度。
  static const int nonceLength = 12;

  /// GCM 认证标签长度。
  static const int tagLength = 16;

  /// DEK 长度（256-bit）。
  static const int dekLength = 32;

  /// 单个 key slot 长度：type(1) + nonce(12) + ciphertext(32) + tag(16)。
  static const int keySlotLength = 61;

  /// 头部固定前缀长度（不含 payload_nonce/tag、key_slots、payload）：
  /// 19+4+1+1+4+4+4+16 = 53；该前缀同时是 AEAD 的 AAD。
  static const int aadPrefixLength = 53;

  /// 判定 format_version 是否在应用支持范围内。
  static bool isSupportedVersion(int version) =>
      version >= minSupportedFormatVersion &&
      version <= maxSupportedFormatVersion;
}

/// KDF 参数（随文件携带）。
class BackupKdfParams {
  const BackupKdfParams({
    required this.memoryKib,
    required this.iterations,
    required this.parallelism,
  });

  /// Argon2id 内存（KiB）。
  final int memoryKib;

  /// Argon2id 迭代次数。
  final int iterations;

  /// Argon2id 并行度。
  final int parallelism;

  /// 冻结的默认参数（首版：64 MiB / 3 迭代 / 并行 1）。
  static const BackupKdfParams defaults = BackupKdfParams(
    memoryKib: 64 * 1024,
    iterations: 3,
    parallelism: 1,
  );
}

/// 单个 key slot：一种凭据（密码/恢复词/设备密钥）包裹的 DEK。
class BackupKeySlot {
  const BackupKeySlot({
    required this.type,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
  });

  /// slot 类型（0x01 PASSWORD / 0x02 RECOVERY / 0x03 DEVICE_LOCAL）。
  final int type;

  /// 包裹 DEK 的 AEAD nonce（12B，独立随机）。
  final Uint8List nonce;

  /// 包裹 DEK 的密文（32B）。
  final Uint8List ciphertext;

  /// 包裹 DEK 的认证标签（16B）。
  final Uint8List tag;

  /// 序列化为 61B：type + nonce + ciphertext + tag。
  Uint8List toBytes() {
    final out = ByteData(BackupEnvelopeConstants.keySlotLength);
    var offset = 0;
    out.setUint8(offset++, type);
    out.buffer.asUint8List().setRange(offset, offset + nonce.length, nonce);
    offset += nonce.length;
    out.buffer.asUint8List().setRange(
      offset,
      offset + ciphertext.length,
      ciphertext,
    );
    offset += ciphertext.length;
    out.buffer.asUint8List().setRange(offset, offset + tag.length, tag);
    return out.buffer.asUint8List();
  }

  /// 从 61B 解析。
  factory BackupKeySlot.fromBytes(ByteData data, int offset) {
    final type = data.getUint8(offset++);
    if (!BackupEnvelopeConstants.supportedSlotTypes.contains(type)) {
      throw const BackupFormatException(
        BackupOpenError.corrupt,
        '未知 key slot 类型',
      );
    }
    final nonce = Uint8List.view(
      data.buffer,
      data.offsetInBytes + offset,
      BackupEnvelopeConstants.nonceLength,
    );
    offset += BackupEnvelopeConstants.nonceLength;
    final ciphertext = Uint8List.view(
      data.buffer,
      data.offsetInBytes + offset,
      BackupEnvelopeConstants.dekLength,
    );
    offset += BackupEnvelopeConstants.dekLength;
    final tag = Uint8List.view(
      data.buffer,
      data.offsetInBytes + offset,
      BackupEnvelopeConstants.tagLength,
    );
    return BackupKeySlot(
      type: type,
      nonce: nonce,
      ciphertext: ciphertext,
      tag: tag,
    );
  }
}

/// 解析后的 Envelope 结构（不可变）。
class BackupEnvelope {
  const BackupEnvelope({
    required this.formatVersion,
    required this.cryptoScheme,
    required this.kdfScheme,
    required this.kdfParams,
    required this.salt,
    required this.payloadNonce,
    required this.payloadTag,
    required this.keySlots,
    required this.encryptedPayload,
  });

  /// 备份格式版本（与 Manifest 双写校验）。
  final int formatVersion;

  /// 加密方案（0x01 = AES-256-GCM）。
  final int cryptoScheme;

  /// KDF 方案（0x01 = Argon2id）。
  final int kdfScheme;

  /// KDF 参数（随文件携带）。
  final BackupKdfParams kdfParams;

  /// KDF 盐（所有 key slot 共用）。
  final Uint8List salt;

  /// payload AEAD nonce。
  final Uint8List payloadNonce;

  /// payload AEAD 认证标签。
  final Uint8List payloadTag;

  /// 同一 DEK 的各凭据包裹（PASSWORD / RECOVERY / DEVICE_LOCAL）。
  final List<BackupKeySlot> keySlots;

  /// 密文载荷：内含 Manifest + SQLite 备份体。
  final Uint8List encryptedPayload;

  /// AEAD 附加认证数据：头部固定前缀（magic..salt，53B）。
  ///
  /// 设计意图：format_version / crypto_scheme / KDF 参数 / salt 一旦被
  /// 篡改，解密在密码学层面认证失败，而不是"解析碰巧失败"。
  Uint8List get aad {
    final out = ByteData(BackupEnvelopeConstants.aadPrefixLength);
    var offset = 0;
    for (final b in BackupEnvelopeConstants.magic) {
      out.setUint8(offset++, b);
    }
    out.setUint32(offset, formatVersion);
    offset += 4;
    out.setUint8(offset++, cryptoScheme);
    out.setUint8(offset++, kdfScheme);
    out.setUint32(offset, kdfParams.memoryKib);
    offset += 4;
    out.setUint32(offset, kdfParams.iterations);
    offset += 4;
    out.setUint32(offset, kdfParams.parallelism);
    offset += 4;
    out.buffer.asUint8List().setRange(offset, offset + salt.length, salt);
    return out.buffer.asUint8List();
  }
}

/// Envelope 编解码器：只负责冻结的二进制布局，不涉及任何密钥与加解密。
class BackupEnvelopeCodec {
  BackupEnvelopeCodec._();

  /// 编码为文件字节流（头部 + slots + payload 原样追加）。
  static Uint8List encode(BackupEnvelope envelope) {
    final slotsLength =
        envelope.keySlots.length * BackupEnvelopeConstants.keySlotLength;
    final out = ByteData(
      BackupEnvelopeConstants.aadPrefixLength +
          BackupEnvelopeConstants.nonceLength +
          BackupEnvelopeConstants.tagLength +
          1 +
          slotsLength +
          envelope.encryptedPayload.length,
    );
    var offset = 0;
    for (final b in BackupEnvelopeConstants.magic) {
      out.setUint8(offset++, b);
    }
    out.setUint32(offset, envelope.formatVersion);
    offset += 4;
    out.setUint8(offset++, envelope.cryptoScheme);
    out.setUint8(offset++, envelope.kdfScheme);
    out.setUint32(offset, envelope.kdfParams.memoryKib);
    offset += 4;
    out.setUint32(offset, envelope.kdfParams.iterations);
    offset += 4;
    out.setUint32(offset, envelope.kdfParams.parallelism);
    offset += 4;
    out.buffer.asUint8List().setRange(
      offset,
      offset + envelope.salt.length,
      envelope.salt,
    );
    offset += envelope.salt.length;
    // 固定前缀结束（offset == aadPrefixLength）→ payload nonce/tag
    out.buffer.asUint8List().setRange(
      offset,
      offset + envelope.payloadNonce.length,
      envelope.payloadNonce,
    );
    offset += envelope.payloadNonce.length;
    out.buffer.asUint8List().setRange(
      offset,
      offset + envelope.payloadTag.length,
      envelope.payloadTag,
    );
    offset += envelope.payloadTag.length;
    out.setUint8(offset++, envelope.keySlots.length);
    for (final slot in envelope.keySlots) {
      final bytes = slot.toBytes();
      out.buffer.asUint8List().setRange(offset, offset + bytes.length, bytes);
      offset += bytes.length;
    }
    out.buffer.asUint8List().setRange(
      offset,
      offset + envelope.encryptedPayload.length,
      envelope.encryptedPayload,
    );
    return out.buffer.asUint8List();
  }

  /// 解析文件字节流；任何结构问题抛出 [BackupFormatException]（带分类原因）。
  ///
  /// 校验顺序刻意固定：magic → 长度 → 版本范围 → 方案——先排除"不是备份文件"
  /// 再谈版本，保证旧格式/损坏文件都得到各自准确的用户提示。
  static BackupEnvelope decode(Uint8List bytes) {
    final minimum =
        BackupEnvelopeConstants.aadPrefixLength +
        BackupEnvelopeConstants.nonceLength +
        BackupEnvelopeConstants.tagLength +
        1; // payload nonce/tag + slot_count
    if (bytes.length < minimum) {
      throw const BackupFormatException(BackupOpenError.corrupt, '文件过短，不是合法备份');
    }
    final data = ByteData.sublistView(bytes);
    var offset = 0;
    for (final b in BackupEnvelopeConstants.magic) {
      if (data.getUint8(offset++) != b) {
        throw const BackupFormatException(
          BackupOpenError.corrupt,
          '魔数不匹配：非备份文件或旧格式',
        );
      }
    }
    final formatVersion = data.getUint32(offset);
    offset += 4;
    if (!BackupEnvelopeConstants.isSupportedVersion(formatVersion)) {
      throw BackupFormatException(
        BackupOpenError.unsupportedVersion,
        '备份格式版本 $formatVersion 不受支持（应用支持 [${BackupEnvelopeConstants.minSupportedFormatVersion}, '
        '${BackupEnvelopeConstants.maxSupportedFormatVersion}]）',
      );
    }
    final cryptoScheme = data.getUint8(offset++);
    if (cryptoScheme != BackupEnvelopeConstants.cryptoSchemeAes256Gcm) {
      throw const BackupFormatException(
        BackupOpenError.unsupportedScheme,
        '加密方案未实现',
      );
    }
    final kdfScheme = data.getUint8(offset++);
    if (kdfScheme != BackupEnvelopeConstants.kdfSchemeArgon2id) {
      throw const BackupFormatException(
        BackupOpenError.unsupportedScheme,
        'KDF 方案未实现',
      );
    }
    final kdfParams = BackupKdfParams(
      memoryKib: data.getUint32(offset),
      iterations: data.getUint32(offset + 4),
      parallelism: data.getUint32(offset + 8),
    );
    offset += 12;
    if (kdfParams.memoryKib < 1024 ||
        kdfParams.iterations < 1 ||
        kdfParams.parallelism < 1) {
      throw const BackupFormatException(BackupOpenError.corrupt, 'KDF 参数非法');
    }
    final salt = Uint8List.sublistView(
      bytes,
      offset,
      offset + BackupEnvelopeConstants.saltLength,
    );
    offset += BackupEnvelopeConstants.saltLength;

    final payloadNonce = Uint8List.sublistView(
      bytes,
      offset,
      offset + BackupEnvelopeConstants.nonceLength,
    );
    offset += BackupEnvelopeConstants.nonceLength;
    final payloadTag = Uint8List.sublistView(
      bytes,
      offset,
      offset + BackupEnvelopeConstants.tagLength,
    );
    offset += BackupEnvelopeConstants.tagLength;
    final slotCount = data.getUint8(offset++);
    if (slotCount < 1 || slotCount > 3) {
      throw const BackupFormatException(
        BackupOpenError.corrupt,
        'key slot 数量非法',
      );
    }
    final slotsEnd = offset + slotCount * BackupEnvelopeConstants.keySlotLength;
    if (bytes.length < slotsEnd) {
      throw const BackupFormatException(
        BackupOpenError.corrupt,
        'key slot 数据截断',
      );
    }
    final keySlots = <BackupKeySlot>[];
    for (var i = 0; i < slotCount; i++) {
      keySlots.add(
        BackupKeySlot.fromBytes(
          data,
          offset + i * BackupEnvelopeConstants.keySlotLength,
        ),
      );
    }
    offset = slotsEnd;
    final encryptedPayload = Uint8List.sublistView(bytes, offset);
    return BackupEnvelope(
      formatVersion: formatVersion,
      cryptoScheme: cryptoScheme,
      kdfScheme: kdfScheme,
      kdfParams: kdfParams,
      salt: salt,
      payloadNonce: payloadNonce,
      payloadTag: payloadTag,
      keySlots: keySlots,
      encryptedPayload: encryptedPayload,
    );
  }
}

/// 解密后 payload 的分帧编解码：[u32 manifest 长度][manifest JSON][u32 sqlite 长度][SQLite 体]。
class BackupPayloadCodec {
  BackupPayloadCodec._();

  /// 分帧编码。
  static Uint8List encode(Uint8List manifestJson, Uint8List sqliteBytes) {
    final out = ByteData(8 + manifestJson.length + sqliteBytes.length);
    out.setUint32(0, manifestJson.length);
    out.setUint32(4, sqliteBytes.length);
    out.buffer.asUint8List().setRange(8, 8 + manifestJson.length, manifestJson);
    out.buffer.asUint8List().setRange(
      8 + manifestJson.length,
      8 + manifestJson.length + sqliteBytes.length,
      sqliteBytes,
    );
    return out.buffer.asUint8List();
  }

  /// 分帧解码；长度字段越界或截断 → corrupt。
  static ({Uint8List manifestJson, Uint8List sqliteBytes}) decode(
    Uint8List bytes,
  ) {
    if (bytes.length < 8) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧过短');
    }
    final data = ByteData.sublistView(bytes);
    final manifestLength = data.getUint32(0);
    final sqliteLength = data.getUint32(4);
    final total = 8 + manifestLength + sqliteLength;
    if (total > bytes.length) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧长度字段损坏');
    }
    return (
      manifestJson: Uint8List.sublistView(bytes, 8, 8 + manifestLength),
      sqliteBytes: Uint8List.sublistView(bytes, 8 + manifestLength, total),
    );
  }
}
