// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of10_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum_memoEntry =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum._(
        'memoEntry');

PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'memoEntry':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum_memoEntry;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum_memoEntry,
]);

const PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnumValueOf(
        String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'memoEntry': 'memo_entry',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'memo_entry': 'memoEntry',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf10AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String? ledgerId;
  @override
  final String? dayBookId;
  @override
  final String memoBookId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final DateTime updatedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf10AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf._(
      {required this.mutationId,
      required this.entityType,
      required this.entityId,
      this.ledgerId,
      this.dayBookId,
      required this.memoBookId,
      this.syncId,
      this.baseRevision,
      required this.updatedAt,
      required this.action,
      required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf10AnyOf &&
        mutationId == other.mutationId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        ledgerId == other.ledgerId &&
        dayBookId == other.dayBookId &&
        memoBookId == other.memoBookId &&
        syncId == other.syncId &&
        baseRevision == other.baseRevision &&
        updatedAt == other.updatedAt &&
        action == other.action &&
        payload == other.payload;
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
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf10AnyOf')
          ..add('mutationId', mutationId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('ledgerId', ledgerId)
          ..add('dayBookId', dayBookId)
          ..add('memoBookId', memoBookId)
          ..add('syncId', syncId)
          ..add('baseRevision', baseRevision)
          ..add('updatedAt', updatedAt)
          ..add('action', action)
          ..add('payload', payload))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf10AnyOf,
            PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfEntityTypeEnum?
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

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf10AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf10AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _ledgerId = $v.ledgerId;
      _dayBookId = $v.dayBookId;
      _memoBookId = $v.memoBookId;
      _syncId = $v.syncId;
      _baseRevision = $v.baseRevision;
      _updatedAt = $v.updatedAt;
      _action = $v.action;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf10AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf10AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf10AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: BuiltValueNullFieldError.checkNotNull(memoBookId,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'memoBookId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOf', 'action'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf10AnyOf',
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
