// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum_ledger =
    const PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum._('ledger');

PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'ledger':
      return _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum_ledger;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum_ledger,
]);

const PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ledger': 'ledger',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ledger': 'ledger',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf
    extends PostSyncPushRequestChangesInnerAnyOfAnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOfAnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOfAnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOfAnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOfAnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOfAnyOf')
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

class PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOfAnyOf,
            PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOfAnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOfAnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOfAnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOfAnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOfAnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOfAnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOfAnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOfAnyOf',
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
