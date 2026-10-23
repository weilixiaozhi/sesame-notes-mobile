// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of12_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum_fitnessPlan =
    const PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum._(
        'fitnessPlan');

PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPlan':
      return _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum_fitnessPlan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum_fitnessPlan,
]);

const PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnumValueOf(
        String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlan': 'fitness_plan',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_plan': 'fitnessPlan',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf12AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum entityType;
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
  final PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload payload;
  @override
  final DateTime? deletedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf12AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf12AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf12AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf12AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf12AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf12AnyOf,
            PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf12AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf12AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf12AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf12AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf12AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf12AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf12AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf12AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: memoBookId,
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf',
                'fitnessSpaceId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOf', 'action'),
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
            r'PostSyncPushRequestChangesInnerAnyOf12AnyOf',
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
