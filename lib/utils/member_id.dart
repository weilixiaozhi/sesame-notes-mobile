/// 成员 id 确定性派生工具。
///
/// REGISTERED 成员使用与服务端一致的 UUIDv5(ledgerId, user:账号 id)；
/// LOCAL 成员按本地身份键派生。同一账本和身份可重新算出同一个 member_id，
/// 不同账本的成员 id 各自独立；云端成员快照与交易引用直接使用该成员 id。
/// PLACEHOLDER 成员使用其自身 UUID，不经过本工具。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// 把标准 UUID 字符串解析为 16 字节（RFC 4122 二进制布局）。
///
/// 空串或不足 32 个字符的 namespace 使用全零命名空间。
/// 达到长度后解析前 16 字节，非十六进制字符由解析器报告格式错误。
Uint8List _uuidBytes(String uuid) {
  final hex = uuid.replaceAll('-', '');
  final bytes = Uint8List(16);
  if (hex.length < 32) return bytes;
  for (var i = 0; i < 16; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

/// 计算 UUIDv5（SHA-1 命名空间 + 名称），输出小写标准格式。
///
/// 同参数永远返回同一 id；参数顺序（账本在前、身份键在后）是派生约定，
/// 改动会破坏存量成员映射，必须保持稳定。
String uuidV5(String namespace, String name) {
  final ns = _uuidBytes(namespace);
  final nameBytes = utf8.encode(name);
  final data = Uint8List(ns.length + nameBytes.length)
    ..setRange(0, ns.length, ns)
    ..setRange(ns.length, ns.length + nameBytes.length, nameBytes);
  final hash = sha1.convert(data).bytes;
  // RFC 4122：第 6 字节高 4 位置版本号 5；第 8 字节高 2 位置变体 10。
  hash[6] = (hash[6] & 0x0f) | 0x50;
  hash[8] = (hash[8] & 0x3f) | 0x80;
  final h = hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  // 第 5 段必须截取 12 字符（h[20..32)），否则产出 44 字符非标准串。
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
}

/// 本地账本「我」成员的派生键：同一账本 + 同一设备身份 → 同一 member_id。
String localSelfMemberId(String ledgerId, String localSelfId) =>
    uuidV5(ledgerId, 'self:${localSelfId.toLowerCase()}');

/// 恢复 Fork 时源 LOCAL self 成员的确定性派生键：
/// 以原成员 id 为身份键，保证同源账本多次 Fork 得到同一"历史我"成员。
String localSelfMemberIdFromOriginal(
  String ledgerId,
  String originalMemberId,
) => uuidV5(ledgerId, 'self-orig:${originalMemberId.toLowerCase()}');

/// 已绑定云端账号成员的派生键：同一账本 + 同一云 userId → 同一 member_id。
///
/// userId 统一按小写规范化后再派生：数据库 UUID 通常已规范化为小写，
/// 但派生算法必须对同一账号的不同大小写表示产出同一个 id。
String registeredMemberId(String ledgerId, String userId) =>
    uuidV5(ledgerId, 'user:${userId.toLowerCase()}');
