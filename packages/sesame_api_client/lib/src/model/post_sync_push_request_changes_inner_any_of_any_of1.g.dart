// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum_ledger =
    const PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum._('ledger');

PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'ledger':
      return _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum_ledger;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum_ledger,
]);

const PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ledger': 'ledger',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ledger': 'ledger',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1
    extends PostSyncPushRequestChangesInnerAnyOfAnyOf1 {
  @override
  final String mutationId;
  @override
  final PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final String ledgerId;
  @override
  final String? syncId;
  @override
  final int? baseRevision;
  @override
  final PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum action;
  @override
  final DateTime updatedAt;
  @override
  final JsonObject payload;

  factory _$PostSyncPushRequestChangesInnerAnyOfAnyOf1(
          [void Function(PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1._(
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
  PostSyncPushRequestChangesInnerAnyOfAnyOf1 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOfAnyOf1 &&
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
            r'PostSyncPushRequestChangesInnerAnyOfAnyOf1')
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

class PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOfAnyOf1,
            PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder> {
  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum? _entityType;
  PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum? _action;
  PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum? get action =>
      _$this._action;
  set action(PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum? action) =>
      _$this._action = action;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder() {
    PostSyncPushRequestChangesInnerAnyOfAnyOf1._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder get _$this {
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
      _payload = $v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOfAnyOf1 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOfAnyOf1;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOfAnyOf1._(
          mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'mutationId'),
          entityType: BuiltValueNullFieldError.checkNotNull(entityType,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'entityType'),
          entityId: BuiltValueNullFieldError.checkNotNull(entityId,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'entityId'),
          ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'ledgerId'),
          syncId: syncId,
          baseRevision: baseRevision,
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'action'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'updatedAt'),
          payload: BuiltValueNullFieldError.checkNotNull(payload,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOf1', 'payload'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
