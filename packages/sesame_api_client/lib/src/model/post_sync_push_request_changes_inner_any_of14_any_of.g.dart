// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of14_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum_fitnessPreferences =
    const PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum._(
        'fitnessPreferences');

PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPreferences':
      return _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum_fitnessPreferences;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum_fitnessPreferences,
]);

const PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnumValueOf(
        String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf14AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPreferences': 'fitness_preferences',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_preferences': 'fitnessPreferences',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf14AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf14AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum entityType;
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
  final PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload payload;
  @override
  final DateTime? deletedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf14AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf14AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf14AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf14AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf14AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf14AnyOf,
            PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf14AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf14AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf14AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf14AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf14AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf14AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf14AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf14AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf14AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf14AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: memoBookId,
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf',
                'fitnessSpaceId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOf', 'action'),
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
            r'PostSyncPushRequestChangesInnerAnyOf14AnyOf',
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
