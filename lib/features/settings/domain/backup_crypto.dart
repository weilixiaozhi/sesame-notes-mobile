/// 备份加密链路：Argon2id KDF + AES-256-GCM Envelope。
///
/// - KDF：Argon2id，**参数随 Envelope 携带**，输入 = 凭据字符串 + 文件内 salt；
/// - Multi-Key-Slot：同一 DEK 分别被 密码 / 恢复词 / 设备密钥 的 KEK 包裹，
///   任一凭据解开对应 slot 即得同一 DEK——忘记密码可凭恢复词恢复；
/// - payload 与 DEK 包裹的 AEAD 均使用头部固定前缀作为 AAD；
/// - 恢复词 16 组 × 256 词表 = 128 bit 熵；
/// - 设备密钥不得作为唯一保护手段：DEVICE_LOCAL slot 仅本机兜底。
///
/// 失败语义：所有凭据均无法解开任何 slot（密码/恢复词错误、数据损坏）统一归类为
/// wrongPasswordOrCorrupted，调用方据此拒绝恢复且保证 live DB 0 mutation。
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';

import 'backup_envelope.dart';

/// 备份凭据集合（Multi-Key-Slot 的输入）。
///
/// 至少提供一个凭据；密码/恢复词/设备密钥各自派生 KEK 包裹同一 DEK。
class BackupSecrets {
  const BackupSecrets({this.password, this.recoveryKey, this.deviceKey});

  /// 备份密码（用户输入）。
  final String? password;

  /// 恢复词（16 组，128 bit 熵）。
  final String? recoveryKey;

  /// 设备密钥（localSelfId 派生，仅本机兜底）。
  final String? deviceKey;

  /// 是否至少有一个凭据。
  bool get hasAny =>
      password != null || recoveryKey != null || deviceKey != null;
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

  /// Recovery Key 词数：16 组（256 词表 × 16 = 128 bit 熵）。
  static const int recoveryKeyWordCount = 16;

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

  /// 用一组凭据创建完整 Envelope：随机盐 + 随机 DEK + 各凭据 key slot + payload 加密。
  ///
  /// [password] / [recoveryKey] / [deviceKey] 至少提供一个（Multi-Key-Slot）。
  /// [kdfParams] 缺省为冻结默认参数（64 MiB/3/1），并写入文件头。
  static Future<BackupEnvelope> createEnvelope({
    required Uint8List plaintextPayload,
    String? password,
    String? recoveryKey,
    String? deviceKey,
    BackupKdfParams? kdfParams,
  }) async {
    if (password == null && recoveryKey == null && deviceKey == null) {
      throw ArgumentError('至少提供一个凭据（密码/恢复词/设备密钥）');
    }
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

    final slots = <BackupKeySlot>[];
    if (password != null) {
      final kek = await _deriveKek(password, salt, params);
      slots.add(
        await _wrapDek(kek, dek, BackupEnvelopeConstants.slotTypePassword, aad),
      );
    }
    if (recoveryKey != null) {
      final kek = await _deriveKek(recoveryKey, salt, params);
      slots.add(
        await _wrapDek(kek, dek, BackupEnvelopeConstants.slotTypeRecovery, aad),
      );
    }
    if (deviceKey != null) {
      final kek = await _deriveKek(deviceKey, salt, params);
      slots.add(
        await _wrapDek(
          kek,
          dek,
          BackupEnvelopeConstants.slotTypeDeviceLocal,
          aad,
        ),
      );
    }

    return BackupEnvelope(
      formatVersion: BackupEnvelopeConstants.formatVersion,
      cryptoScheme: BackupEnvelopeConstants.cryptoSchemeAes256Gcm,
      kdfScheme: BackupEnvelopeConstants.kdfSchemeArgon2id,
      kdfParams: params,
      salt: salt,
      payloadNonce: Uint8List.fromList(box.nonce),
      payloadTag: Uint8List.fromList(box.mac.bytes),
      keySlots: slots,
      encryptedPayload: Uint8List.fromList(box.cipherText),
    );
  }

  /// 用任一凭据解密 Envelope 的 payload。
  ///
  /// 匹配规则：密码 → PASSWORD slot；恢复词 → RECOVERY slot；设备密钥 → DEVICE_LOCAL slot。
  /// 所有凭据都试过后仍无 slot 可解 → wrongPasswordOrCorrupted。
  /// 返回分帧明文（调用方用 BackupPayloadCodec.decode 解出 Manifest + SQLite 体）。
  static Future<Uint8List> decryptEnvelopePayload({
    required BackupEnvelope envelope,
    String? password,
    String? recoveryKey,
    String? deviceKey,
  }) async {
    final candidates = <(int, SecretKey)>[];
    if (password != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypePassword,
        await _deriveKek(password, envelope.salt, envelope.kdfParams),
      ));
    }
    if (recoveryKey != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypeRecovery,
        await _deriveKek(recoveryKey, envelope.salt, envelope.kdfParams),
      ));
    }
    if (deviceKey != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypeDeviceLocal,
        await _deriveKek(deviceKey, envelope.salt, envelope.kdfParams),
      ));
    }
    if (candidates.isEmpty) {
      throw ArgumentError('至少提供一个凭据（密码/恢复词/设备密钥）');
    }
    final aad = envelope.aad;
    Uint8List? dek;
    for (final (slotType, kek) in candidates) {
      for (final slot in envelope.keySlots) {
        if (slot.type != slotType) continue;
        dek = await _unwrapSlot(slot, kek, aad);
        if (dek != null) break;
      }
      if (dek != null) break;
    }
    if (dek == null) {
      throw const BackupFormatException(
        BackupOpenError.wrongPasswordOrCorrupted,
        '提供的凭据均无法解开备份（密码/恢复词错误或文件损坏）',
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
        BackupOpenError.wrongPasswordOrCorrupted,
        'payload 解密失败：密码错误或文件损坏',
      );
    }
  }

  /// 修改凭据（改密码语义）：用旧凭据解出 DEK → 用新凭据重包对应 slot，
  /// payload 一字节不动。返回重写后的 Envelope。
  ///
  /// [oldPassword]/[oldRecoveryKey]/[oldDeviceKey] 提供一个即可解 DEK；
  /// [newPassword]/[newRecoveryKey]/[newDeviceKey] 提供哪个就重包哪个 slot
  /// （未提供的旧 slot 保留）。
  static Future<BackupEnvelope> rewrapDek({
    required BackupEnvelope envelope,
    String? oldPassword,
    String? oldRecoveryKey,
    String? oldDeviceKey,
    String? newPassword,
    String? newRecoveryKey,
    String? newDeviceKey,
  }) async {
    // 1) 用旧凭据解出 DEK（不验证 payload，只需 DEK 正确）
    final candidates = <(int, SecretKey)>[];
    if (oldPassword != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypePassword,
        await _deriveKek(oldPassword, envelope.salt, envelope.kdfParams),
      ));
    }
    if (oldRecoveryKey != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypeRecovery,
        await _deriveKek(oldRecoveryKey, envelope.salt, envelope.kdfParams),
      ));
    }
    if (oldDeviceKey != null) {
      candidates.add((
        BackupEnvelopeConstants.slotTypeDeviceLocal,
        await _deriveKek(oldDeviceKey, envelope.salt, envelope.kdfParams),
      ));
    }
    final aad = envelope.aad;
    Uint8List? dek;
    for (final (slotType, kek) in candidates) {
      for (final slot in envelope.keySlots) {
        if (slot.type != slotType) continue;
        dek = await _unwrapSlot(slot, kek, aad);
        if (dek != null) break;
      }
      if (dek != null) break;
    }
    if (dek == null) {
      throw const BackupFormatException(
        BackupOpenError.wrongPasswordOrCorrupted,
        '旧凭据无法解开备份',
      );
    }
    // 2) 保留未替换的旧 slot，重包新凭据的 slot
    final slots = <BackupKeySlot>[];
    final replaced = <int>{};
    if (newPassword != null) {
      final kek = await _deriveKek(
        newPassword,
        envelope.salt,
        envelope.kdfParams,
      );
      slots.add(
        await _wrapDek(kek, dek, BackupEnvelopeConstants.slotTypePassword, aad),
      );
      replaced.add(BackupEnvelopeConstants.slotTypePassword);
    }
    if (newRecoveryKey != null) {
      final kek = await _deriveKek(
        newRecoveryKey,
        envelope.salt,
        envelope.kdfParams,
      );
      slots.add(
        await _wrapDek(kek, dek, BackupEnvelopeConstants.slotTypeRecovery, aad),
      );
      replaced.add(BackupEnvelopeConstants.slotTypeRecovery);
    }
    if (newDeviceKey != null) {
      final kek = await _deriveKek(
        newDeviceKey,
        envelope.salt,
        envelope.kdfParams,
      );
      slots.add(
        await _wrapDek(
          kek,
          dek,
          BackupEnvelopeConstants.slotTypeDeviceLocal,
          aad,
        ),
      );
      replaced.add(BackupEnvelopeConstants.slotTypeDeviceLocal);
    }
    for (final slot in envelope.keySlots) {
      if (!replaced.contains(slot.type)) slots.add(slot);
    }
    return BackupEnvelope(
      formatVersion: envelope.formatVersion,
      cryptoScheme: envelope.cryptoScheme,
      kdfScheme: envelope.kdfScheme,
      kdfParams: envelope.kdfParams,
      salt: envelope.salt,
      payloadNonce: envelope.payloadNonce,
      payloadTag: envelope.payloadTag,
      keySlots: slots,
      encryptedPayload: envelope.encryptedPayload,
    );
  }

  /// 设备绑定密钥：localSelfId 派生（DEVICE_LOCAL slot 的 KDF 输入，仅本机兜底）。
  static String deviceKeyFromLocalSelfId(String localSelfId) => sha256
      .convert(utf8.encode('sesame-notes-backup:$localSelfId'))
      .toString();

  /// 生成 16 组恢复词（从冻结词表随机抽取，128 bit 熵）。
  static List<String> generateRecoveryKeyWords() {
    final words = <String>[];
    final used = <int>{};
    while (words.length < recoveryKeyWordCount) {
      final index = _random.nextInt(_recoveryWordList.length);
      if (used.add(index)) words.add(_recoveryWordList[index]);
    }
    return words;
  }

  /// 归一化恢复词输入：小写 + 空白折叠，保证不同输入形态映射同一密钥。
  static String normalizeRecoveryKey(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 恢复词哈希（本地校验用，与打开备份的解密无关）；空输入返回空串。
  static String hashRecoveryKey(String raw) {
    final normalized = normalizeRecoveryKey(raw);
    if (normalized.isEmpty) return '';
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  /// 校验恢复词与哈希匹配（恒定时间比较防时序侧信道）。
  static bool verifyRecoveryKey(String raw, String expectedHash) {
    final normalized = normalizeRecoveryKey(raw);
    if (normalized.isEmpty || expectedHash.isEmpty) return false;
    final actual = hashRecoveryKey(normalized);
    if (actual.length != expectedHash.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// 密码校验哈希（快速 sha256，仅设置页 UX 校验输入，不承载备份保密性）。
  static String hashPasswordVerifier(String password) =>
      sha256.convert(utf8.encode('sesame-notes-verifier:$password')).toString();

  /// 恒定时间校验密码校验哈希。
  static bool verifyPasswordVerifier(String password, String expected) {
    final actual = hashPasswordVerifier(password);
    if (actual.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return diff == 0;
  }

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

  /// 冻结恢复词表（256 词，每词 8 bit 熵，16 词合计 128 bit）。
  static const List<String> _recoveryWordList = [
    'abacus',
    'abbey',
    'acorn',
    'adobe',
    'agenda',
    'aisle',
    'alarm',
    'album',
    'amber',
    'anchor',
    'anvil',
    'apricot',
    'arcade',
    'arena',
    'arrow',
    'atlas',
    'avenue',
    'awning',
    'badge',
    'bagel',
    'bamboo',
    'banjo',
    'barnacle',
    'basil',
    'bazaar',
    'beacon',
    'beetle',
    'biscuit',
    'blazer',
    'blossom',
    'bonfire',
    'boulder',
    'bramble',
    'breeze',
    'bride',
    'bubble',
    'budget',
    'buffalo',
    'bullet',
    'bumper',
    'burrow',
    'butter',
    'cabinet',
    'cactus',
    'camel',
    'candle',
    'canoe',
    'canyon',
    'caper',
    'carnival',
    'castle',
    'cathedral',
    'cedar',
    'celery',
    'chalk',
    'chapel',
    'charcoal',
    'cherry',
    'chimney',
    'cinnamon',
    'citrus',
    'clover',
    'coastal',
    'cobalt',
    'cobra',
    'comet',
    'compass',
    'coral',
    'cottage',
    'courier',
    'cranberry',
    'crescent',
    'cricket',
    'crocus',
    'crystal',
    'cuckoo',
    'curtain',
    'cyclone',
    'daffodil',
    'dagger',
    'dandelion',
    'dartboard',
    'dawn',
    'dewdrop',
    'diamond',
    'dinosaur',
    'dolphin',
    'donkey',
    'dragon',
    'drum',
    'duckling',
    'dune',
    'eagle',
    'easel',
    'eclipse',
    'ember',
    'emerald',
    'falcon',
    'feather',
    'fence',
    'fern',
    'ferry',
    'fig',
    'firefly',
    'fjord',
    'flamingo',
    'flint',
    'flute',
    'forest',
    'fossil',
    'foxglove',
    'freedom',
    'frost',
    'galaxy',
    'garden',
    'garnet',
    'geyser',
    'ginger',
    'glacier',
    'globe',
    'goblin',
    'granite',
    'grape',
    'grove',
    'guitar',
    'gull',
    'harbor',
    'harvest',
    'hazel',
    'heather',
    'heron',
    'hickory',
    'hillside',
    'honey',
    'horizon',
    'hunter',
    'hurricane',
    'hymn',
    'iceberg',
    'iguana',
    'incense',
    'indigo',
    'iris',
    'island',
    'ivory',
    'jaguar',
    'jasmine',
    'javelin',
    'jellyfish',
    'jewel',
    'juniper',
    'kayak',
    'kettle',
    'kingfisher',
    'kitten',
    'koala',
    'lantern',
    'larkspur',
    'lava',
    'lemon',
    'lichen',
    'lighthouse',
    'lilac',
    'lily',
    'linen',
    'lion',
    'lizard',
    'lobster',
    'lotus',
    'lumber',
    'lynx',
    'magnet',
    'magnolia',
    'maple',
    'marble',
    'marigold',
    'meadow',
    'mercury',
    'meteor',
    'mint',
    'mist',
    'monsoon',
    'moonstone',
    'moose',
    'morning',
    'mosaic',
    'moss',
    'mountain',
    'mulberry',
    'mushroom',
    'mustard',
    'napkin',
    'nectar',
    'needle',
    'nest',
    'nickel',
    'nightingale',
    'north',
    'novel',
    'oak',
    'oasis',
    'ocean',
    'octopus',
    'olive',
    'onyx',
    'orchid',
    'oriole',
    'otter',
    'owl',
    'oyster',
    'paddle',
    'palace',
    'palm',
    'panda',
    'papaya',
    'parrot',
    'pasture',
    'pebble',
    'pelican',
    'pepper',
    'phoenix',
    'piano',
    'picnic',
    'pigeon',
    'pillow',
    'pine',
    'pioneer',
    'pixel',
    'plum',
    'poppy',
    'porch',
    'prairie',
    'prism',
    'pumpkin',
    'pyramid',
    'quail',
    'quartz',
    'quill',
    'quiver',
    'rabbit',
    'radish',
    'rainbow',
    'raven',
    'reed',
    'reef',
    'rhino',
    'ridge',
    'river',
    'robin',
    'rocket',
    'rose',
    'ruby',
    'saffron',
    'sail',
    'salamander',
    'salmon',
    'sapphire',
    'satellite',
    'savanna',
    'scallop',
    'scarlet',
    'seaweed',
    'sequoia',
    'shadow',
    'shark',
    'sheep',
    'shell',
    'silver',
    'skylark',
    'slate',
    'snail',
    'snowdrop',
    'soapstone',
    'sparrow',
    'spice',
    'spiral',
    'sprout',
    'squirrel',
    'starlight',
    'steel',
    'stone',
    'strawberry',
    'summit',
    'sunflower',
    'surf',
    'swallow',
    'swan',
    'tadpole',
    'tangerine',
    'teapot',
    'tempest',
    'thistle',
    'thunder',
    'tide',
    'timber',
    'topaz',
    'tornado',
    'toucan',
    'trail',
    'treasure',
    'trout',
    'tulip',
    'tundra',
    'turquoise',
    'turtle',
    'twilight',
    'umbrella',
    'valley',
    'violet',
    'volcano',
    'walnut',
    'wave',
    'whale',
    'willow',
    'winter',
    'wisteria',
    'wombat',
    'woodland',
    'yacht',
    'zephyr',
    'zinnia',
    'zodiac',
  ];
}
