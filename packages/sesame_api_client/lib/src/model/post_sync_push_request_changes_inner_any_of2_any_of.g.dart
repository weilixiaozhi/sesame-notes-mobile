// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of2_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum_category =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum._(
        'category');

PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'category':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum_category;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum_category,
]);

const PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'category': 'category',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'category': 'category',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf2AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf2AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf2AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf2AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf2AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf2AnyOf,
            PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf2AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf2AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf2AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf2AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf2AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf2AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf2AnyOf', 'entityId'),
            ledgerId: ledgerId,
            syncId: syncId,
            baseRevision: baseRevision,
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf2AnyOf', 'action'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf2AnyOf', 'updatedAt'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf2AnyOf',
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
