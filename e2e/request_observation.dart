import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

/// 只读观察生成 SDK 对象和冻结 JSON 正文，保持实际传输对象及字节不变。
Map<String, dynamic> observedRequestBody(Object? body) {
  try {
    final decoded = body is String ? jsonDecode(body) : body;
    if (decoded is! Map) {
      throw const FormatException('验收请求正文必须是 JSON 对象');
    }
    return Map<String, dynamic>.from(decoded);
  } catch (error, stackTrace) {
    printOnFailure('读取验收请求正文失败：${error.runtimeType}\n$stackTrace');
    rethrow;
  }
}

/// 冻结请求按原始 JSON 字节记录，生成 SDK 对象使用正常 JSON 序列化结果。
String observedRequestJson(Object? body) {
  try {
    return body is String ? body : jsonEncode(body);
  } catch (error, stackTrace) {
    printOnFailure('记录验收请求原文失败：${error.runtimeType}\n$stackTrace');
    rethrow;
  }
}
