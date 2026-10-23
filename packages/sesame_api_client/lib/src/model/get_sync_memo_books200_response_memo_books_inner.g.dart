// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_memo_books200_response_memo_books_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum
    _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_normal =
    const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum._('normal');
const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum
    _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_credentials =
    const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum._('credentials');

GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum
    _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumValueOf(String name) {
  switch (name) {
    case 'normal':
      return _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_normal;
    case 'credentials':
      return _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_credentials;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>
    _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumValues = BuiltSet<
        GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>(const <GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>[
  _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_normal,
  _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_credentials,
]);

Serializer<GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>
    _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumSerializer =
    _$GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnumSerializer();

class _$GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnumSerializer
    implements
        PrimitiveSerializer<GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'normal': 'normal',
    'credentials': 'credentials',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'normal': 'normal',
    'credentials': 'credentials',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum
  ];
  @override
  final String wireName = 'GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncMemoBooks200ResponseMemoBooksInner
    extends GetSyncMemoBooks200ResponseMemoBooksInner {
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
  final GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum type;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime? deletedAt;
  @override
  final int entryCount;

  factory _$GetSyncMemoBooks200ResponseMemoBooksInner(
          [void Function(GetSyncMemoBooks200ResponseMemoBooksInnerBuilder)?
              updates]) =>
      (GetSyncMemoBooks200ResponseMemoBooksInnerBuilder()..update(updates))
          ._build();

  _$GetSyncMemoBooks200ResponseMemoBooksInner._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor,
      required this.type,
      required this.id,
      required this.syncId,
      required this.revision,
      this.deletedAt,
      required this.entryCount})
      : super._();
  @override
  GetSyncMemoBooks200ResponseMemoBooksInner rebuild(
          void Function(GetSyncMemoBooks200ResponseMemoBooksInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncMemoBooks200ResponseMemoBooksInnerBuilder toBuilder() =>
      GetSyncMemoBooks200ResponseMemoBooksInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncMemoBooks200ResponseMemoBooksInner &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor &&
        type == other.type &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt &&
        entryCount == other.entryCount;
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
    _$hash = $jc(_$hash, entryCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncMemoBooks200ResponseMemoBooksInner')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor)
          ..add('type', type)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt)
          ..add('entryCount', entryCount))
        .toString();
  }
}

class GetSyncMemoBooks200ResponseMemoBooksInnerBuilder
    implements
        Builder<GetSyncMemoBooks200ResponseMemoBooksInner,
            GetSyncMemoBooks200ResponseMemoBooksInnerBuilder> {
  _$GetSyncMemoBooks200ResponseMemoBooksInner? _$v;

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

  GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum? _type;
  GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum? get type => _$this._type;
  set type(GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum? type) =>
      _$this._type = type;

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

  int? _entryCount;
  int? get entryCount => _$this._entryCount;
  set entryCount(int? entryCount) => _$this._entryCount = entryCount;

  GetSyncMemoBooks200ResponseMemoBooksInnerBuilder() {
    GetSyncMemoBooks200ResponseMemoBooksInner._defaults(this);
  }

  GetSyncMemoBooks200ResponseMemoBooksInnerBuilder get _$this {
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
      _entryCount = $v.entryCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncMemoBooks200ResponseMemoBooksInner other) {
    _$v = other as _$GetSyncMemoBooks200ResponseMemoBooksInner;
  }

  @override
  void update(
      void Function(GetSyncMemoBooks200ResponseMemoBooksInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncMemoBooks200ResponseMemoBooksInner build() => _build();

  _$GetSyncMemoBooks200ResponseMemoBooksInner _build() {
    final _$result = _$v ??
        _$GetSyncMemoBooks200ResponseMemoBooksInner._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetSyncMemoBooks200ResponseMemoBooksInner', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'GetSyncMemoBooks200ResponseMemoBooksInner', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'GetSyncMemoBooks200ResponseMemoBooksInner', 'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'GetSyncMemoBooks200ResponseMemoBooksInner', 'type'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetSyncMemoBooks200ResponseMemoBooksInner', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'GetSyncMemoBooks200ResponseMemoBooksInner', 'syncId'),
          revision: BuiltValueNullFieldError.checkNotNull(revision,
              r'GetSyncMemoBooks200ResponseMemoBooksInner', 'revision'),
          deletedAt: deletedAt,
          entryCount: BuiltValueNullFieldError.checkNotNull(entryCount,
              r'GetSyncMemoBooks200ResponseMemoBooksInner', 'entryCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
