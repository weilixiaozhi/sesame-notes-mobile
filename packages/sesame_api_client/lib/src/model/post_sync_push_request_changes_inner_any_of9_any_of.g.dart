// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of9_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum_memoBook =
    const PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum._(
        'memoBook');

PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'memoBook':
      return _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum_memoBook;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum_memoBook,
]);

const PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum_upsert =
    const PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum._('upsert');

PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum_upsert;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum_upsert,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'memoBook': 'memo_book',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'memo_book': 'memoBook',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOf
    extends PostSyncPushRequestChangesInnerAnyOf9AnyOf {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum entityType;
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
  final PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum action;
  @override
  final PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf9AnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf._(
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
  PostSyncPushRequestChangesInnerAnyOf9AnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf9AnyOf &&
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
            r'PostSyncPushRequestChangesInnerAnyOf9AnyOf')
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

class PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf9AnyOf,
            PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum? action) =>
      _$this._action = action;

  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf9AnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf9AnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf9AnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf _build() {
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOf _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf9AnyOf._(
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'mutationId'),
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(entityId,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'entityId'),
            ledgerId: ledgerId,
            dayBookId: dayBookId,
            memoBookId: BuiltValueNullFieldError.checkNotNull(memoBookId,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'memoBookId'),
            syncId: syncId,
            baseRevision: baseRevision,
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'updatedAt'),
            action: BuiltValueNullFieldError.checkNotNull(action,
                r'PostSyncPushRequestChangesInnerAnyOf9AnyOf', 'action'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf9AnyOf',
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
