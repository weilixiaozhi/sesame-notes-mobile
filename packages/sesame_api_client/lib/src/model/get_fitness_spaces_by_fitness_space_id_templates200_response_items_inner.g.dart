// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner
    extends GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner {
  @override
  final String name;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>
      exercises;
  @override
  final GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?
      catalogOrigin;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String id;
  @override
  final String fitnessSpaceId;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final String? deletedAt;

  factory _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner._(
      {required this.name,
      required this.exercises,
      this.catalogOrigin,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.fitnessSpaceId,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner &&
        name == other.name &&
        exercises == other.exercises &&
        catalogOrigin == other.catalogOrigin &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        id == other.id &&
        fitnessSpaceId == other.fitnessSpaceId &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jc(_$hash, catalogOrigin.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fitnessSpaceId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner')
          ..add('name', name)
          ..add('exercises', exercises)
          ..add('catalogOrigin', catalogOrigin)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('id', id)
          ..add('fitnessSpaceId', fitnessSpaceId)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>?
      _exercises;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>
      get exercises => _$this._exercises ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>();
  set exercises(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>?
              exercises) =>
      _$this._exercises = exercises;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder?
      _catalogOrigin;
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
      get catalogOrigin => _$this._catalogOrigin ??=
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder();
  set catalogOrigin(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder?
              catalogOrigin) =>
      _$this._catalogOrigin = catalogOrigin;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fitnessSpaceId;
  String? get fitnessSpaceId => _$this._fitnessSpaceId;
  set fitnessSpaceId(String? fitnessSpaceId) =>
      _$this._fitnessSpaceId = fitnessSpaceId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _deletedAt;
  String? get deletedAt => _$this._deletedAt;
  set deletedAt(String? deletedAt) => _$this._deletedAt = deletedAt;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _exercises = $v.exercises.toBuilder();
      _catalogOrigin = $v.catalogOrigin?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _id = $v.id;
      _fitnessSpaceId = $v.fitnessSpaceId;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner _build() {
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner._(
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'name'),
            exercises: exercises.build(),
            catalogOrigin: _catalogOrigin?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'updatedAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'id'),
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'fitnessSpaceId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
                'revision'),
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exercises';
        exercises.build();
        _$failedField = 'catalogOrigin';
        _catalogOrigin?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner',
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
