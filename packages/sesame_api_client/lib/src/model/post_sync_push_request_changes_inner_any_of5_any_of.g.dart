// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of5_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum_member =
    const PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum._('member');

PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'member':
      return _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum_member,
]);

const PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf5AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf5AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf5AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf5AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf5AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf5AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf5AnyOf,
            PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf5AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf5AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf5AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf5AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf5AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf5AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf5AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf5AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf5AnyOf',
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
