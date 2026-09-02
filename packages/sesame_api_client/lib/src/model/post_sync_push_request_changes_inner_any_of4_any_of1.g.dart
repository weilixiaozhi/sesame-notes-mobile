// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of4_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum_exchangeRateOverride =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum._(
        'exchangeRateOverride');

PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'exchangeRateOverride':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum_exchangeRateOverride;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum_exchangeRateOverride,
]);

const PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnumValueOf(
        String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exchangeRateOverride': 'exchange_rate_override',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exchange_rate_override': 'exchangeRateOverride',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1
    extends PostSyncPushRequestChangesInnerAnyOf4AnyOf1 {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final JsonObject payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1(
          [void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      this.ledgerId,
      this.syncId,
      this.baseRevision,
      required this.action,
      required this.updatedAt,
      required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf4AnyOf1 &&
        mutationId == other.mutationId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        ledgerId == other.ledgerId &&
        syncId == other.syncId &&
        baseRevision == other.baseRevision &&
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
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1')
          ..add('mutationId', mutationId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('ledgerId', ledgerId)
          ..add('syncId', syncId)
          ..add('baseRevision', baseRevision)
          ..add('action', action)
          ..add('updatedAt', updatedAt)
          ..add('payload', payload))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf4AnyOf1,
            PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum?
              entityType) =>
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

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder() {
    PostSyncPushRequestChangesInnerAnyOf4AnyOf1._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _ledgerId = $v.ledgerId;
      _syncId = $v.syncId;
      _baseRevision = $v.baseRevision;
      _action = $v.action;
      _updatedAt = $v.updatedAt;
      _payload = $v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf4AnyOf1 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOf1Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf1 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf4AnyOf1._(
          mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'mutationId'),
          entityType: BuiltValueNullFieldError.checkNotNull(entityType,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'entityType'),
          entityId: BuiltValueNullFieldError.checkNotNull(entityId,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'entityId'),
          ledgerId: ledgerId,
          syncId: syncId,
          baseRevision: baseRevision,
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'action'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'updatedAt'),
          payload: BuiltValueNullFieldError.checkNotNull(payload,
              r'PostSyncPushRequestChangesInnerAnyOf4AnyOf1', 'payload'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
