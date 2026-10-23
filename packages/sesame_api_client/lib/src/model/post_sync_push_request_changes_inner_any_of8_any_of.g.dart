// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of8_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum_member =
    const PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum._('member');

PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'member':
      return _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum_member,
]);

const PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf8AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf8AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf8AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf8AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf8AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf8AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf8AnyOf,
            PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf8AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf8AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf8AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf8AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf8AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf8AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf8AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf8AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf8AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf8AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'entityId'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'ledgerId'),
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf8AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf8AnyOf',
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
