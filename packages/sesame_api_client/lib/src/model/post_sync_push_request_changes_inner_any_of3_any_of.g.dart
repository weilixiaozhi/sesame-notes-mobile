// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of3_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum_recurringTransaction =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum._(
        'recurringTransaction');

PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'recurringTransaction':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum_recurringTransaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum_recurringTransaction,
]);

const PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'recurringTransaction': 'recurring_transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'recurring_transaction': 'recurringTransaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf3AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf3AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf3AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf3AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf3AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf3AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf3AnyOf,
            PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf3AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf3AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf3AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf3AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf3AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf3AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf3AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf3AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf3AnyOf',
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
