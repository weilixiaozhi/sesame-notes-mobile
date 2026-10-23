// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MemoEntryBookTypeEnum _$memoEntryBookTypeEnum_normal =
    const MemoEntryBookTypeEnum._('normal');
const MemoEntryBookTypeEnum _$memoEntryBookTypeEnum_credentials =
    const MemoEntryBookTypeEnum._('credentials');

MemoEntryBookTypeEnum _$memoEntryBookTypeEnumValueOf(String name) {
  switch (name) {
    case 'normal':
      return _$memoEntryBookTypeEnum_normal;
    case 'credentials':
      return _$memoEntryBookTypeEnum_credentials;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemoEntryBookTypeEnum> _$memoEntryBookTypeEnumValues =
    BuiltSet<MemoEntryBookTypeEnum>(const <MemoEntryBookTypeEnum>[
  _$memoEntryBookTypeEnum_normal,
  _$memoEntryBookTypeEnum_credentials,
]);

const MemoEntryBodyFormatEnum _$memoEntryBodyFormatEnum_deltaV1 =
    const MemoEntryBodyFormatEnum._('deltaV1');
const MemoEntryBodyFormatEnum _$memoEntryBodyFormatEnum_fieldsV1 =
    const MemoEntryBodyFormatEnum._('fieldsV1');

MemoEntryBodyFormatEnum _$memoEntryBodyFormatEnumValueOf(String name) {
  switch (name) {
    case 'deltaV1':
      return _$memoEntryBodyFormatEnum_deltaV1;
    case 'fieldsV1':
      return _$memoEntryBodyFormatEnum_fieldsV1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemoEntryBodyFormatEnum> _$memoEntryBodyFormatEnumValues =
    BuiltSet<MemoEntryBodyFormatEnum>(const <MemoEntryBodyFormatEnum>[
  _$memoEntryBodyFormatEnum_deltaV1,
  _$memoEntryBodyFormatEnum_fieldsV1,
]);

Serializer<MemoEntryBookTypeEnum> _$memoEntryBookTypeEnumSerializer =
    _$MemoEntryBookTypeEnumSerializer();
Serializer<MemoEntryBodyFormatEnum> _$memoEntryBodyFormatEnumSerializer =
    _$MemoEntryBodyFormatEnumSerializer();

class _$MemoEntryBookTypeEnumSerializer
    implements PrimitiveSerializer<MemoEntryBookTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'normal': 'normal',
    'credentials': 'credentials',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'normal': 'normal',
    'credentials': 'credentials',
  };

  @override
  final Iterable<Type> types = const <Type>[MemoEntryBookTypeEnum];
  @override
  final String wireName = 'MemoEntryBookTypeEnum';

  @override
  Object serialize(Serializers serializers, MemoEntryBookTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MemoEntryBookTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MemoEntryBookTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MemoEntryBodyFormatEnumSerializer
    implements PrimitiveSerializer<MemoEntryBodyFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'deltaV1': 'delta_v1',
    'fieldsV1': 'fields_v1',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delta_v1': 'deltaV1',
    'fields_v1': 'fieldsV1',
  };

  @override
  final Iterable<Type> types = const <Type>[MemoEntryBodyFormatEnum];
  @override
  final String wireName = 'MemoEntryBodyFormatEnum';

  @override
  Object serialize(Serializers serializers, MemoEntryBodyFormatEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MemoEntryBodyFormatEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MemoEntryBodyFormatEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MemoEntry extends MemoEntry {
  @override
  final MemoEntryBookTypeEnum bookType;
  @override
  final String title;
  @override
  final MemoEntryBodyFormatEnum? bodyFormat;
  @override
  final BuiltMap<String, JsonObject?>? body;
  @override
  final String? orderKey;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime? deletedAt;
  @override
  final String memoBookId;
  @override
  final DateTime bookUpdatedAt;

  factory _$MemoEntry([void Function(MemoEntryBuilder)? updates]) =>
      (MemoEntryBuilder()..update(updates))._build();

  _$MemoEntry._(
      {required this.bookType,
      required this.title,
      this.bodyFormat,
      this.body,
      this.orderKey,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.syncId,
      required this.revision,
      this.deletedAt,
      required this.memoBookId,
      required this.bookUpdatedAt})
      : super._();
  @override
  MemoEntry rebuild(void Function(MemoEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MemoEntryBuilder toBuilder() => MemoEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemoEntry &&
        bookType == other.bookType &&
        title == other.title &&
        bodyFormat == other.bodyFormat &&
        body == other.body &&
        orderKey == other.orderKey &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt &&
        memoBookId == other.memoBookId &&
        bookUpdatedAt == other.bookUpdatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bookType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, bodyFormat.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, orderKey.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, memoBookId.hashCode);
    _$hash = $jc(_$hash, bookUpdatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemoEntry')
          ..add('bookType', bookType)
          ..add('title', title)
          ..add('bodyFormat', bodyFormat)
          ..add('body', body)
          ..add('orderKey', orderKey)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt)
          ..add('memoBookId', memoBookId)
          ..add('bookUpdatedAt', bookUpdatedAt))
        .toString();
  }
}

class MemoEntryBuilder implements Builder<MemoEntry, MemoEntryBuilder> {
  _$MemoEntry? _$v;

  MemoEntryBookTypeEnum? _bookType;
  MemoEntryBookTypeEnum? get bookType => _$this._bookType;
  set bookType(MemoEntryBookTypeEnum? bookType) => _$this._bookType = bookType;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  MemoEntryBodyFormatEnum? _bodyFormat;
  MemoEntryBodyFormatEnum? get bodyFormat => _$this._bodyFormat;
  set bodyFormat(MemoEntryBodyFormatEnum? bodyFormat) =>
      _$this._bodyFormat = bodyFormat;

  MapBuilder<String, JsonObject?>? _body;
  MapBuilder<String, JsonObject?> get body =>
      _$this._body ??= MapBuilder<String, JsonObject?>();
  set body(MapBuilder<String, JsonObject?>? body) => _$this._body = body;

  String? _orderKey;
  String? get orderKey => _$this._orderKey;
  set orderKey(String? orderKey) => _$this._orderKey = orderKey;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  String? _memoBookId;
  String? get memoBookId => _$this._memoBookId;
  set memoBookId(String? memoBookId) => _$this._memoBookId = memoBookId;

  DateTime? _bookUpdatedAt;
  DateTime? get bookUpdatedAt => _$this._bookUpdatedAt;
  set bookUpdatedAt(DateTime? bookUpdatedAt) =>
      _$this._bookUpdatedAt = bookUpdatedAt;

  MemoEntryBuilder() {
    MemoEntry._defaults(this);
  }

  MemoEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bookType = $v.bookType;
      _title = $v.title;
      _bodyFormat = $v.bodyFormat;
      _body = $v.body?.toBuilder();
      _orderKey = $v.orderKey;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _id = $v.id;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _memoBookId = $v.memoBookId;
      _bookUpdatedAt = $v.bookUpdatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemoEntry other) {
    _$v = other as _$MemoEntry;
  }

  @override
  void update(void Function(MemoEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemoEntry build() => _build();

  _$MemoEntry _build() {
    _$MemoEntry _$result;
    try {
      _$result = _$v ??
          _$MemoEntry._(
            bookType: BuiltValueNullFieldError.checkNotNull(
                bookType, r'MemoEntry', 'bookType'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'MemoEntry', 'title'),
            bodyFormat: bodyFormat,
            body: _body?.build(),
            orderKey: orderKey,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'MemoEntry', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'MemoEntry', 'updatedAt'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'MemoEntry', 'id'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId, r'MemoEntry', 'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'MemoEntry', 'revision'),
            deletedAt: deletedAt,
            memoBookId: BuiltValueNullFieldError.checkNotNull(
                memoBookId, r'MemoEntry', 'memoBookId'),
            bookUpdatedAt: BuiltValueNullFieldError.checkNotNull(
                bookUpdatedAt, r'MemoEntry', 'bookUpdatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'body';
        _body?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MemoEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
