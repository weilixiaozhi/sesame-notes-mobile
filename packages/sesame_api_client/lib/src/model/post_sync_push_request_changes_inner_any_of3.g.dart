// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of3.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_ledgerArchive =
    const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum._(
        'ledgerArchive');

PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'ledgerArchive':
      return _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_ledgerArchive;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_ledgerArchive,
]);

const PostSyncPushRequestChangesInnerAnyOf3ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf3ActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf3ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf3ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ledgerArchive': 'ledger_archive',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ledger_archive': 'ledgerArchive',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf3ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3
    extends PostSyncPushRequestChangesInnerAnyOf3 {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String syncId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3ActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3Payload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf3(
          [void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf3Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf3._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      required this.ledgerId,
      required this.syncId,
      required this.action,
      required this.updatedAt,
      required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf3 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf3Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf3Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf3 &&
        mutationId == other.mutationId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        ledgerId == other.ledgerId &&
        syncId == other.syncId &&
        action == other.action &&
        updatedAt == other.updatedAt &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf3')
          ..add('mutationId', mutationId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('ledgerId', ledgerId)
          ..add('syncId', syncId)
          ..add('action', action)
          ..add('updatedAt', updatedAt)
          ..add('payload', payload))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf3Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf3,
            PostSyncPushRequestChangesInnerAnyOf3Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf3? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum? entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  PostSyncPushRequestChangesInnerAnyOf3ActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf3ActionEnum? get action => _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf3ActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder get payload =>
      _$this._payload ??= PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder();
  set payload(PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf3Builder() {
    PostSyncPushRequestChangesInnerAnyOf3._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf3Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _ledgerId = $v.ledgerId;
      _syncId = $v.syncId;
      _action = $v.action;
      _updatedAt = $v.updatedAt;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf3 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf3;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf3 _build() {
    _$PostSyncPushRequestChangesInnerAnyOf3 _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf3._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf3', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf3', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(
                entityId, r'PostSyncPushRequestChangesInnerAnyOf3', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(
                ledgerId, r'PostSyncPushRequestChangesInnerAnyOf3', 'ledgerId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId, r'PostSyncPushRequestChangesInnerAnyOf3', 'syncId'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'PostSyncPushRequestChangesInnerAnyOf3', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf3', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf3',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
