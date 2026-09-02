// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of1_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum_transaction =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum._(
        'transaction');

PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'transaction':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum_transaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum_transaction,
]);

const PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'transaction': 'transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'transaction': 'transaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf1AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf1AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf1AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf1AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf1AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf1AnyOf,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf1AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf1AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf1AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf1AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf1AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf1AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf1AnyOf',
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
