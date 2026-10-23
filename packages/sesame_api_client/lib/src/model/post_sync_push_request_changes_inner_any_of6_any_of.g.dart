// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of6_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum_recurringTransaction =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum._(
        'recurringTransaction');

PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'recurringTransaction':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum_recurringTransaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum_recurringTransaction,
]);

const PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'recurringTransaction': 'recurring_transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'recurring_transaction': 'recurringTransaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf6AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf6AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOf._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      required this.ledgerId,
      this.syncId,
      this.baseRevision,
      required this.action,
      required this.updatedAt,
      required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf6AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf6AnyOf,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf6AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf6AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf6AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf6AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOf',
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
