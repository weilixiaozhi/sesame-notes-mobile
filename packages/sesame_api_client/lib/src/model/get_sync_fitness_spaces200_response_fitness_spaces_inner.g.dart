// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_fitness_spaces200_response_fitness_spaces_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner
    extends GetSyncFitnessSpaces200ResponseFitnessSpacesInner {
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
  @override
  final int entityCount;

  factory _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner(
          [void Function(
                  GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder)?
              updates]) =>
      (GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor,
      required this.id,
      required this.syncId,
      required this.revision,
      this.deletedAt,
      required this.entityCount})
      : super._();
  @override
  GetSyncFitnessSpaces200ResponseFitnessSpacesInner rebuild(
          void Function(
                  GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder toBuilder() =>
      GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFitnessSpaces200ResponseFitnessSpacesInner &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt &&
        entityCount == other.entityCount;
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
    _$hash = $jc(_$hash, entityCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt)
          ..add('entityCount', entityCount))
        .toString();
  }
}

class GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder
    implements
        Builder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner,
            GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder> {
  _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner? _$v;

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

  int? _entityCount;
  int? get entityCount => _$this._entityCount;
  set entityCount(int? entityCount) => _$this._entityCount = entityCount;

  GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder() {
    GetSyncFitnessSpaces200ResponseFitnessSpacesInner._defaults(this);
  }

  GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder get _$this {
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
      _entityCount = $v.entityCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFitnessSpaces200ResponseFitnessSpacesInner other) {
    _$v = other as _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner;
  }

  @override
  void update(
      void Function(GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFitnessSpaces200ResponseFitnessSpacesInner build() => _build();

  _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner _build() {
    final _$result = _$v ??
        _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner',
              'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner',
              'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(syncId,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner', 'syncId'),
          revision: BuiltValueNullFieldError.checkNotNull(revision,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner', 'revision'),
          deletedAt: deletedAt,
          entityCount: BuiltValueNullFieldError.checkNotNull(
              entityCount,
              r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner',
              'entityCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
