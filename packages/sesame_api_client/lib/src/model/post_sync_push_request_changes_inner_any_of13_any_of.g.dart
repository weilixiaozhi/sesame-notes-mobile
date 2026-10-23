// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of13_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum_fitnessWorkout =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum._(
        'fitnessWorkout');

PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessWorkout':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum_fitnessWorkout;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum_fitnessWorkout,
]);

const PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnumValueOf(
        String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessWorkout': 'fitness_workout',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_workout': 'fitnessWorkout',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf13AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum entityType;
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
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload payload;
  @override
  final DateTime? deletedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf13AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf13AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf13AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf13AnyOf,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf13AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf13AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf13AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf13AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf13AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf13AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: memoBookId,
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf',
                'fitnessSpaceId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOf', 'action'),
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
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOf',
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
