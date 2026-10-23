// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_book.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MemoBookTypeEnum _$memoBookTypeEnum_normal =
    const MemoBookTypeEnum._('normal');
const MemoBookTypeEnum _$memoBookTypeEnum_credentials =
    const MemoBookTypeEnum._('credentials');

MemoBookTypeEnum _$memoBookTypeEnumValueOf(String name) {
  switch (name) {
    case 'normal':
      return _$memoBookTypeEnum_normal;
    case 'credentials':
      return _$memoBookTypeEnum_credentials;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MemoBookTypeEnum> _$memoBookTypeEnumValues =
    BuiltSet<MemoBookTypeEnum>(const <MemoBookTypeEnum>[
  _$memoBookTypeEnum_normal,
  _$memoBookTypeEnum_credentials,
]);

Serializer<MemoBookTypeEnum> _$memoBookTypeEnumSerializer =
    _$MemoBookTypeEnumSerializer();

class _$MemoBookTypeEnumSerializer
    implements PrimitiveSerializer<MemoBookTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'normal': 'normal',
    'credentials': 'credentials',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'normal': 'normal',
    'credentials': 'credentials',
  };

  @override
  final Iterable<Type> types = const <Type>[MemoBookTypeEnum];
  @override
  final String wireName = 'MemoBookTypeEnum';

  @override
  Object serialize(Serializers serializers, MemoBookTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MemoBookTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MemoBookTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MemoBook extends MemoBook {
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool? restore;
  @override
  final String? expectedFullCursor;
  @override
  final MemoBookTypeEnum type;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime? deletedAt;

  factory _$MemoBook([void Function(MemoBookBuilder)? updates]) =>
      (MemoBookBuilder()..update(updates))._build();

  _$MemoBook._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor,
      required this.type,
      required this.id,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  MemoBook rebuild(void Function(MemoBookBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MemoBookBuilder toBuilder() => MemoBookBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MemoBook &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor &&
        type == other.type &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, restore.hashCode);
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MemoBook')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor)
          ..add('type', type)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class MemoBookBuilder implements Builder<MemoBook, MemoBookBuilder> {
  _$MemoBook? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _restore;
  bool? get restore => _$this._restore;
  set restore(bool? restore) => _$this._restore = restore;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  MemoBookTypeEnum? _type;
  MemoBookTypeEnum? get type => _$this._type;
  set type(MemoBookTypeEnum? type) => _$this._type = type;

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

  MemoBookBuilder() {
    MemoBook._defaults(this);
  }

  MemoBookBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _restore = $v.restore;
      _expectedFullCursor = $v.expectedFullCursor;
      _type = $v.type;
      _id = $v.id;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MemoBook other) {
    _$v = other as _$MemoBook;
  }

  @override
  void update(void Function(MemoBookBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MemoBook build() => _build();

  _$MemoBook _build() {
    final _$result = _$v ??
        _$MemoBook._(
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'MemoBook', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'MemoBook', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'MemoBook', 'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
          type:
              BuiltValueNullFieldError.checkNotNull(type, r'MemoBook', 'type'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'MemoBook', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'MemoBook', 'syncId'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'MemoBook', 'revision'),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
