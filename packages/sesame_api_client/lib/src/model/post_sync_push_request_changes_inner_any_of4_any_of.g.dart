// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of4_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum_exchangeRateOverride =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum._(
        'exchangeRateOverride');

PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'exchangeRateOverride':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum_exchangeRateOverride;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum_exchangeRateOverride,
]);

const PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exchangeRateOverride': 'exchange_rate_override',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exchange_rate_override': 'exchangeRateOverride',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf4AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf4AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf4AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf4AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf4AnyOf,
            PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf4AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder get _$this {
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
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf4AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf4AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf4AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOf', 'entityId'),
            ledgerId: ledgerId,
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOf',
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
