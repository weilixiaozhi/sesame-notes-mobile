// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of11_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum_fitnessTemplate =
    const PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum._(
        'fitnessTemplate');

PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessTemplate':
      return _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum_fitnessTemplate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum_fitnessTemplate,
]);

const PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumValueOf(
        String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessTemplate': 'fitness_template',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_template': 'fitnessTemplate',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf11AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? dayBookId;
  @override
  final String? memoBookId;
  @override
  final String fitnessSpaceId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload payload;
  @override
  final DateTime? deletedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf11AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf11AnyOf._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      this.ledgerId,
      this.dayBookId,
      this.memoBookId,
      required this.fitnessSpaceId,
      this.syncId,
      this.baseRevision,
      required this.updatedAt,
      required this.action,
      required this.payload,
      this.deletedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf11AnyOf &&
        mutationId == other.mutationId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        ledgerId == other.ledgerId &&
        dayBookId == other.dayBookId &&
        memoBookId == other.memoBookId &&
        fitnessSpaceId == other.fitnessSpaceId &&
        syncId == other.syncId &&
        baseRevision == other.baseRevision &&
        updatedAt == other.updatedAt &&
        action == other.action &&
        payload == other.payload &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, dayBookId.hashCode);
    _$hash = $jc(_$hash, memoBookId.hashCode);
    _$hash = $jc(_$hash, fitnessSpaceId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf11AnyOf')
          ..add('mutationId', mutationId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('ledgerId', ledgerId)
          ..add('dayBookId', dayBookId)
          ..add('memoBookId', memoBookId)
          ..add('fitnessSpaceId', fitnessSpaceId)
          ..add('syncId', syncId)
          ..add('baseRevision', baseRevision)
          ..add('updatedAt', updatedAt)
          ..add('action', action)
          ..add('payload', payload)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf11AnyOf,
            PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf11AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _dayBookId;
  String? get dayBookId => _$this._dayBookId;
  set dayBookId(String? dayBookId) => _$this._dayBookId = dayBookId;

  String? _memoBookId;
  String? get memoBookId => _$this._memoBookId;
  set memoBookId(String? memoBookId) => _$this._memoBookId = memoBookId;

  String? _fitnessSpaceId;
  String? get fitnessSpaceId => _$this._fitnessSpaceId;
  set fitnessSpaceId(String? fitnessSpaceId) =>
      _$this._fitnessSpaceId = fitnessSpaceId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf11AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _ledgerId = $v.ledgerId;
      _dayBookId = $v.dayBookId;
      _memoBookId = $v.memoBookId;
      _fitnessSpaceId = $v.fitnessSpaceId;
      _syncId = $v.syncId;
      _baseRevision = $v.baseRevision;
      _updatedAt = $v.updatedAt;
      _action = $v.action;
      _payload = $v.payload.toBuilder();
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf11AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf11AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf11AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf11AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: memoBookId,
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf',
                'fitnessSpaceId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf11AnyOf', 'action'),
            payload: payload.build(),
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf11AnyOf',
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
