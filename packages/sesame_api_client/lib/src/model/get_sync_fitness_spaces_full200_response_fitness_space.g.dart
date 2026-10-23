// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_fitness_spaces_full200_response_fitness_space.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFitnessSpacesFull200ResponseFitnessSpace
    extends GetSyncFitnessSpacesFull200ResponseFitnessSpace {
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool? restore;
  @override
  final String? expectedFullCursor;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime? deletedAt;

  factory _$GetSyncFitnessSpacesFull200ResponseFitnessSpace(
          [void Function(
                  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder)?
              updates]) =>
      (GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder()
            ..update(updates))
          ._build();

  _$GetSyncFitnessSpacesFull200ResponseFitnessSpace._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor,
      required this.id,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  GetSyncFitnessSpacesFull200ResponseFitnessSpace rebuild(
          void Function(GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder toBuilder() =>
      GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFitnessSpacesFull200ResponseFitnessSpace &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, restore.hashCode);
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncFitnessSpacesFull200ResponseFitnessSpace')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder
    implements
        Builder<GetSyncFitnessSpacesFull200ResponseFitnessSpace,
            GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder> {
  _$GetSyncFitnessSpacesFull200ResponseFitnessSpace? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _restore;
  bool? get restore => _$this._restore;
  set restore(bool? restore) => _$this._restore = restore;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder() {
    GetSyncFitnessSpacesFull200ResponseFitnessSpace._defaults(this);
  }

  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _restore = $v.restore;
      _expectedFullCursor = $v.expectedFullCursor;
      _id = $v.id;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFitnessSpacesFull200ResponseFitnessSpace other) {
    _$v = other as _$GetSyncFitnessSpacesFull200ResponseFitnessSpace;
  }

  @override
  void update(
      void Function(GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFitnessSpacesFull200ResponseFitnessSpace build() => _build();

  _$GetSyncFitnessSpacesFull200ResponseFitnessSpace _build() {
    final _$result = _$v ??
        _$GetSyncFitnessSpacesFull200ResponseFitnessSpace._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(syncId,
              r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'syncId'),
          revision: BuiltValueNullFieldError.checkNotNull(revision,
              r'GetSyncFitnessSpacesFull200ResponseFitnessSpace', 'revision'),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
