/// 成员 id 确定性派生工具。
///
/// 设计意图：REGISTERED/LOCAL 成员没有独立的云端契约 id（契约只有 user_id /
/// virtual_user_id），但账务数据必须引用稳定的 member_id。用
/// UUIDv5(ledgerId, 身份键) 派生：同一账本内身份稳定可重入（pull/恢复后能
/// 重新算出同一个 member_id），跨账本不同（同一用户在两个账本各有一个成员）。
/// PLACEHOLDER 成员直接复用虚拟用户 UUID，不经过本工具。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// 把标准 UUID 字符串解析为 16 字节（RFC 4122 二进制布局）。
///
/// 空串/非法 namespace（如新建态账本尚无 ledgerId）容错为全零 namespace，
/// 保证派生函数在任何输入下都有确定输出、不抛异常。
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
  final data = Uint8List(ns.length + utf8.encode(name).length)
    ..setRange(0, ns.length, ns)
    ..setRange(
      ns.length,
      ns.length + utf8.encode(name).length,
      utf8.encode(name),
    );
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
