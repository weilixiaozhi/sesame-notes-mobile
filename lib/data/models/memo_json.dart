import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'memo.dart';

String memoFingerprint(Object? value) {
  Object? canonical(Object? v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: canonical(v[k])};
    }
    if (v is List) return v.map(canonical).toList();
    return v;
  }

  return sha256.convert(utf8.encode(jsonEncode(canonical(value)))).toString();
}

class MemoJsonBook {
  final MemoBook book;
  final List<MemoEntry> entries;
  MemoJsonBook(this.book, List<MemoEntry> entries)
    : entries = List.unmodifiable(entries);
  Map<String, Object?> get json => {
    'source_book_id': book.id,
    ...book.payload,
    'entries': [
      for (final e in entries)
        {'source_entry_id': e.id, 'source_book_id': book.id, ...e.payload},
    ],
  };
}

/// 独立交换格式不携带账号、绑定、水位或待发送请求。
class MemoJsonDocument {
  static const maxBytes = 64 * 1024 * 1024;
  final String exportId;
  final DateTime exportedAt;
  final List<MemoJsonBook> books;
  MemoJsonDocument(this.exportId, this.exportedAt, List<MemoJsonBook> books)
    : books = List.unmodifiable(books);
  Map<String, Object?> get json => {
    'format': 'sesame-memos',
    'schema_version': 2,
    'export_id': exportId,
    'exported_at': wireTimestamp(exportedAt),
    'books': books.map((b) => b.json).toList(),
  };
  List<int> encode() {
    final bytes = utf8.encode(jsonEncode(json));
    if (bytes.length > maxBytes) {
      throw const FormatException('MEMO_JSON_BUDGET');
    }
    return bytes;
  }

  /// 解析单本交换文件，逐条核对身份、正文和原始 JSON 键。
  static MemoJsonDocument decode(List<int> bytes) {
    try {
      if (bytes.length > maxBytes) {
        throw const FormatException('MEMO_JSON_BUDGET');
      }
      final text = utf8.decode(bytes, allowMalformed: false);
      _checkKeys(text);
      final root = _map(jsonDecode(text), {
        'format',
        'schema_version',
        'export_id',
        'exported_at',
        'books',
      });
      if (root['format'] != 'sesame-memos' ||
          root['schema_version'] != 2 ||
          root['books'] is! List ||
          (root['books'] as List).length != 1) {
        throw const FormatException();
      }
      final entryIds = <String>{};
      final books = <MemoJsonBook>[];
      for (final raw in root['books'] as List) {
        final b = _map(raw, {
          'source_book_id',
          'name',
          'type',
          'created_at',
          'updated_at',
          'entries',
        });
        final id = _id(b['source_book_id']);
        if (b['name'] is! String ||
            !isValidName(b['name'] as String) ||
            !['normal', 'credentials'].contains(b['type']) ||
            b['entries'] is! List) {
          throw const FormatException();
        }
        final book = MemoBook(
          id: id,
          name: normalizeName(b['name'] as String),
          type: b['type'] as String,
          createdAt: _time(b['created_at']),
          updatedAt: _time(b['updated_at']),
        );
        final entries = <MemoEntry>[];
        for (final rawEntry in b['entries'] as List) {
          final e = _map(rawEntry, {
            'source_entry_id',
            'source_book_id',
            'book_type',
            'title',
            'body_format',
            'body',
            'order_key',
            'created_at',
            'updated_at',
          });
          final entryId = _id(e['source_entry_id']);
          if (!entryIds.add(entryId) ||
              e['source_book_id'] != id ||
              e['book_type'] != book.type ||
              e['title'] is! String) {
            throw const FormatException();
          }
          final card = book.type == 'credentials';
          // 正文按格式互斥：普通笔记是 delta_v1，账号密码卡片的字段列表是 fields_v1。
          if (e['body_format'] != (card ? 'fields_v1' : 'delta_v1') ||
              e['body'] is! Map) {
            throw const FormatException();
          }
          int? order;
          if (card) {
            if (e['order_key'] is! String ||
                !RegExp(
                  r'^(0|[1-9][0-9]*)$',
                ).hasMatch(e['order_key'] as String)) {
              throw const FormatException();
            }
            order = int.tryParse(e['order_key'] as String);
            if (order == null || order < 0) throw const FormatException();
          } else if (e['order_key'] != null) {
            throw const FormatException();
          }
          final entry = MemoEntry(
            id: entryId,
            memoBookId: id,
            bookType: book.type,
            title: e['title'] as String,
            bodyJson: jsonEncode(e['body']),
            orderKey: order,
            createdAt: _time(e['created_at']),
            updatedAt: _time(e['updated_at']),
          );
          entry.validate();
          entries.add(entry);
        }
        entries.sort(
          (a, b) => book.type == 'credentials'
              ? (a.orderKey!.compareTo(b.orderKey!) != 0
                    ? a.orderKey!.compareTo(b.orderKey!)
                    : a.id.compareTo(b.id))
              : (b.createdAt.compareTo(a.createdAt) != 0
                    ? b.createdAt.compareTo(a.createdAt)
                    : a.id.compareTo(b.id)),
        );
        books.add(MemoJsonBook(book, entries));
      }
      return MemoJsonDocument(
        _id(root['export_id']),
        _time(root['exported_at']),
        books,
      );
    } catch (_) {
      // 解码器原始异常可能包含文件正文；只允许安全分类离开边界。
      throw const FormatException('MEMO_JSON_INVALID');
    }
  }

  /// SQLite 备份逐条校验，不能套用单个 JSON 交换文件的大小限制。
  static void validateSnapshotBook(
    MemoBook book,
    Iterable<MemoEntry> entries, {
    Set<String>? seenIds,
  }) {
    _id(book.id);
    _time(wireTimestamp(book.createdAt));
    _time(wireTimestamp(book.updatedAt));
    if (!isValidName(book.name) ||
        !['normal', 'credentials'].contains(book.type)) {
      throw const FormatException('memo book');
    }
    final ids = seenIds ?? <String>{};
    for (final entry in entries) {
      _id(entry.id);
      _time(wireTimestamp(entry.createdAt));
      _time(wireTimestamp(entry.updatedAt));
      if (!ids.add(entry.id) ||
          entry.memoBookId != book.id ||
          entry.bookType != book.type ||
          (entry.isCard && (entry.orderKey == null || entry.orderKey! < 0))) {
        throw const FormatException('memo identity');
      }
      if (entry.bodyJson == null) throw const FormatException('memo body');
      _checkKeys(entry.bodyJson!);
      entry.validate();
    }
  }

  /// 必须提供全部声明字段，额外字段不参与映射；重复键与嵌套深度由词法校验拦截。
  static Map<String, dynamic> _map(Object? value, Set<String> keys) {
    if (value is! Map<String, dynamic> || !keys.every(value.containsKey)) {
      throw const FormatException();
    }
    return value;
  }

  static String _id(Object? v) {
    if (v is! String ||
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(v)) {
      throw const FormatException();
    }
    return v;
  }

  static DateTime _time(Object? v) {
    if (v is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$').hasMatch(v)) {
      throw const FormatException();
    }
    final date = DateTime.parse(v);
    if (wireTimestamp(date) != v) throw const FormatException();
    return date;
  }

  /// 标准解码器会覆盖重复键；先按 JSON 字符串词法核对每层对象的原始键。
  static void _checkKeys(String text) {
    final stack = <Set<String>?>[];
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '{' || c == '[') {
        stack.add(c == '{' ? <String>{} : null);
        if (stack.length > 32) throw const FormatException();
      } else if (c == '}' || c == ']') {
        if (stack.isEmpty) throw const FormatException();
        stack.removeLast();
      } else if (c == '"') {
        final start = i++;
        while (i < text.length && text[i] != '"') {
          if (text[i] == '\\') i++;
          i++;
        }
        if (i >= text.length) throw const FormatException();
        var next = i + 1;
        while (next < text.length && ' \n\r\t'.contains(text[next])) {
          next++;
        }
        if (next < text.length && text[next] == ':') {
          if (stack.isEmpty ||
              stack.last == null ||
              !stack.last!.add(
                jsonDecode(text.substring(start, i + 1)) as String,
              )) {
            throw const FormatException();
          }
        }
      }
    }
    if (stack.isNotEmpty) throw const FormatException();
  }
}
