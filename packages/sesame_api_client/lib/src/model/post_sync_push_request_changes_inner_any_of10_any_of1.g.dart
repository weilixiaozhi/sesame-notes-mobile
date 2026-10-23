// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of10_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum_memoEntry =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum._(
        'memoEntry');

PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'memoEntry':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum_memoEntry;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum_memoEntry,
]);

const PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnumValueOf(
        String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'memoEntry': 'memo_entry',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'memo_entry': 'memoEntry',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1
    extends PostSyncPushRequestChangesInnerAnyOf10AnyOf1 {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? dayBookId;
  @override
  final String memoBookId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum action;
  @override
  final JsonObject payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1(
          [void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      this.ledgerId,
      this.dayBookId,
      required this.memoBookId,
      this.syncId,
      this.baseRevision,
      required this.updatedAt,
      required this.action,
      required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf10AnyOf1 &&
        mutationId == other.mutationId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        ledgerId == other.ledgerId &&
        dayBookId == other.dayBookId &&
        memoBookId == other.memoBookId &&
        syncId == other.syncId &&
        baseRevision == other.baseRevision &&
        updatedAt == other.updatedAt &&
        action == other.action &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, dayBookId.hashCode);
    _$hash = $jc(_$hash, memoBookId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1')
          ..add('mutationId', mutationId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('ledgerId', ledgerId)
          ..add('dayBookId', dayBookId)
          ..add('memoBookId', memoBookId)
          ..add('syncId', syncId)
          ..add('baseRevision', baseRevision)
          ..add('updatedAt', updatedAt)
          ..add('action', action)
          ..add('payload', payload))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf10AnyOf1,
            PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf10AnyOf1EntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _dayBookId;
  String? get dayBookId => _$this._dayBookId;
  set dayBookId(String? dayBookId) => _$this._dayBookId = dayBookId;

  String? _memoBookId;
  String? get memoBookId => _$this._memoBookId;
  set memoBookId(String? memoBookId) => _$this._memoBookId = memoBookId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf10AnyOf1ActionEnum? action) =>
      _$this._action = action;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder() {
    PostSyncPushRequestChangesInnerAnyOf10AnyOf1._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _ledgerId = $v.ledgerId;
      _dayBookId = $v.dayBookId;
      _memoBookId = $v.memoBookId;
      _syncId = $v.syncId;
      _baseRevision = $v.baseRevision;
      _updatedAt = $v.updatedAt;
      _action = $v.action;
      _payload = $v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf10AnyOf1 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOf1Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf1 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf10AnyOf1._(
          mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'mutationId'),
          entityType: BuiltValueNullFieldError.checkNotNull(entityType,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'entityType'),
          entityId: BuiltValueNullFieldError.checkNotNull(entityId,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'entityId'),
          ledgerId: ledgerId,
          dayBookId: dayBookId,
          memoBookId: BuiltValueNullFieldError.checkNotNull(memoBookId,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'memoBookId'),
          syncId: syncId,
          baseRevision: baseRevision,
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'updatedAt'),
          action: BuiltValueNullFieldError.checkNotNull(action,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'action'),
          payload: BuiltValueNullFieldError.checkNotNull(payload,
              r'PostSyncPushRequestChangesInnerAnyOf10AnyOf1', 'payload'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
