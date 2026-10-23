// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of7_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum_exchangeRateOverride =
    const PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum._(
        'exchangeRateOverride');

PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'exchangeRateOverride':
      return _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum_exchangeRateOverride;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum_exchangeRateOverride,
]);

const PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf7AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exchangeRateOverride': 'exchange_rate_override',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exchange_rate_override': 'exchangeRateOverride',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf7AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf7AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf7AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf7AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf7AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf7AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf7AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf7AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf7AnyOf,
            PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf7AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf7AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf7AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf7AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf7AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf7AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf7AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf7AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf7AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf7AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf7AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf7AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf7AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf7AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf7AnyOf', 'entityId'),
            ledgerId: ledgerId,
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf7AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf7AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf7AnyOf',
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
