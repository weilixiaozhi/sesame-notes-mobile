// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push200_response_outcomes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPush200ResponseOutcomesInnerStatusEnum
    _$postSyncPush200ResponseOutcomesInnerStatusEnum_accepted =
    const PostSyncPush200ResponseOutcomesInnerStatusEnum._('accepted');
const PostSyncPush200ResponseOutcomesInnerStatusEnum
    _$postSyncPush200ResponseOutcomesInnerStatusEnum_ignored =
    const PostSyncPush200ResponseOutcomesInnerStatusEnum._('ignored');
const PostSyncPush200ResponseOutcomesInnerStatusEnum
    _$postSyncPush200ResponseOutcomesInnerStatusEnum_conflict =
    const PostSyncPush200ResponseOutcomesInnerStatusEnum._('conflict');
const PostSyncPush200ResponseOutcomesInnerStatusEnum
    _$postSyncPush200ResponseOutcomesInnerStatusEnum_invalid =
    const PostSyncPush200ResponseOutcomesInnerStatusEnum._('invalid');

PostSyncPush200ResponseOutcomesInnerStatusEnum
    _$postSyncPush200ResponseOutcomesInnerStatusEnumValueOf(String name) {
  switch (name) {
    case 'accepted':
      return _$postSyncPush200ResponseOutcomesInnerStatusEnum_accepted;
    case 'ignored':
      return _$postSyncPush200ResponseOutcomesInnerStatusEnum_ignored;
    case 'conflict':
      return _$postSyncPush200ResponseOutcomesInnerStatusEnum_conflict;
    case 'invalid':
      return _$postSyncPush200ResponseOutcomesInnerStatusEnum_invalid;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPush200ResponseOutcomesInnerStatusEnum>
    _$postSyncPush200ResponseOutcomesInnerStatusEnumValues = BuiltSet<
        PostSyncPush200ResponseOutcomesInnerStatusEnum>(const <PostSyncPush200ResponseOutcomesInnerStatusEnum>[
  _$postSyncPush200ResponseOutcomesInnerStatusEnum_accepted,
  _$postSyncPush200ResponseOutcomesInnerStatusEnum_ignored,
  _$postSyncPush200ResponseOutcomesInnerStatusEnum_conflict,
  _$postSyncPush200ResponseOutcomesInnerStatusEnum_invalid,
]);

Serializer<PostSyncPush200ResponseOutcomesInnerStatusEnum>
    _$postSyncPush200ResponseOutcomesInnerStatusEnumSerializer =
    _$PostSyncPush200ResponseOutcomesInnerStatusEnumSerializer();

class _$PostSyncPush200ResponseOutcomesInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPush200ResponseOutcomesInnerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'accepted': 'accepted',
    'ignored': 'ignored',
    'conflict': 'conflict',
    'invalid': 'invalid',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accepted': 'accepted',
    'ignored': 'ignored',
    'conflict': 'conflict',
    'invalid': 'invalid',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPush200ResponseOutcomesInnerStatusEnum
  ];
  @override
  final String wireName = 'PostSyncPush200ResponseOutcomesInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPush200ResponseOutcomesInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPush200ResponseOutcomesInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPush200ResponseOutcomesInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPush200ResponseOutcomesInner
    extends PostSyncPush200ResponseOutcomesInner {
  @override
  final String mutationId;
  @override
  final String entityId;
  @override
  final PostSyncPush200ResponseOutcomesInnerStatusEnum status;
  @override
  final String? changeId;
  @override
  final String? syncId;
  @override
  final int? revision;
  @override
  final int? currentRevision;
  @override
  final bool? currentDeleted;
  @override
  final JsonObject? currentEntity;
  @override
  final String? message;

  factory _$PostSyncPush200ResponseOutcomesInner(
          [void Function(PostSyncPush200ResponseOutcomesInnerBuilder)?
              updates]) =>
      (PostSyncPush200ResponseOutcomesInnerBuilder()..update(updates))._build();

  _$PostSyncPush200ResponseOutcomesInner._(
      {required this.mutationId,
      required this.entityId,
      required this.status,
      this.changeId,
      this.syncId,
      this.revision,
      this.currentRevision,
      this.currentDeleted,
      this.currentEntity,
      this.message})
      : super._();
  @override
  PostSyncPush200ResponseOutcomesInner rebuild(
          void Function(PostSyncPush200ResponseOutcomesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPush200ResponseOutcomesInnerBuilder toBuilder() =>
      PostSyncPush200ResponseOutcomesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPush200ResponseOutcomesInner &&
        mutationId == other.mutationId &&
        entityId == other.entityId &&
        status == other.status &&
        changeId == other.changeId &&
        syncId == other.syncId &&
        revision == other.revision &&
        currentRevision == other.currentRevision &&
        currentDeleted == other.currentDeleted &&
        currentEntity == other.currentEntity &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, changeId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, currentRevision.hashCode);
    _$hash = $jc(_$hash, currentDeleted.hashCode);
    _$hash = $jc(_$hash, currentEntity.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostSyncPush200ResponseOutcomesInner')
          ..add('mutationId', mutationId)
          ..add('entityId', entityId)
          ..add('status', status)
          ..add('changeId', changeId)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('currentRevision', currentRevision)
          ..add('currentDeleted', currentDeleted)
          ..add('currentEntity', currentEntity)
          ..add('message', message))
        .toString();
  }
}

class PostSyncPush200ResponseOutcomesInnerBuilder
    implements
        Builder<PostSyncPush200ResponseOutcomesInner,
            PostSyncPush200ResponseOutcomesInnerBuilder> {
  _$PostSyncPush200ResponseOutcomesInner? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  PostSyncPush200ResponseOutcomesInnerStatusEnum? _status;
  PostSyncPush200ResponseOutcomesInnerStatusEnum? get status => _$this._status;
  set status(PostSyncPush200ResponseOutcomesInnerStatusEnum? status) =>
      _$this._status = status;

  String? _changeId;
  String? get changeId => _$this._changeId;
  set changeId(String? changeId) => _$this._changeId = changeId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  int? _currentRevision;
  int? get currentRevision => _$this._currentRevision;
  set currentRevision(int? currentRevision) =>
      _$this._currentRevision = currentRevision;

  bool? _currentDeleted;
  bool? get currentDeleted => _$this._currentDeleted;
  set currentDeleted(bool? currentDeleted) =>
      _$this._currentDeleted = currentDeleted;

  JsonObject? _currentEntity;
  JsonObject? get currentEntity => _$this._currentEntity;
  set currentEntity(JsonObject? currentEntity) =>
      _$this._currentEntity = currentEntity;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  PostSyncPush200ResponseOutcomesInnerBuilder() {
    PostSyncPush200ResponseOutcomesInner._defaults(this);
  }

  PostSyncPush200ResponseOutcomesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _entityId = $v.entityId;
      _status = $v.status;
      _changeId = $v.changeId;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _currentRevision = $v.currentRevision;
      _currentDeleted = $v.currentDeleted;
      _currentEntity = $v.currentEntity;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPush200ResponseOutcomesInner other) {
    _$v = other as _$PostSyncPush200ResponseOutcomesInner;
  }

  @override
  void update(
      void Function(PostSyncPush200ResponseOutcomesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPush200ResponseOutcomesInner build() => _build();

  _$PostSyncPush200ResponseOutcomesInner _build() {
    final _$result = _$v ??
        _$PostSyncPush200ResponseOutcomesInner._(
          mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
              r'PostSyncPush200ResponseOutcomesInner', 'mutationId'),
          entityId: BuiltValueNullFieldError.checkNotNull(
              entityId, r'PostSyncPush200ResponseOutcomesInner', 'entityId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PostSyncPush200ResponseOutcomesInner', 'status'),
          changeId: changeId,
          syncId: syncId,
          revision: revision,
          currentRevision: currentRevision,
          currentDeleted: currentDeleted,
          currentEntity: currentEntity,
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
