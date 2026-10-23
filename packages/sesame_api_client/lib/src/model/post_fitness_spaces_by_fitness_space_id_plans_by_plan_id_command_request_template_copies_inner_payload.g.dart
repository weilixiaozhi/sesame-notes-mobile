// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
    extends PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload {
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

  factory _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload._(
      {required this.name,
      required this.exercises,
      this.catalogOrigin,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      rebuild(
              void Function(
                      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
      toBuilder() =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload &&
        name == other.name &&
        exercises == other.exercises &&
        catalogOrigin == other.catalogOrigin &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jc(_$hash, catalogOrigin.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload')
          ..add('name', name)
          ..add('exercises', exercises)
          ..add('catalogOrigin', catalogOrigin)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
    implements
        Builder<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload?
      _$v;

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

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder() {
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
        ._defaults(this);
  }

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _exercises = $v.exercises.toBuilder();
      _catalogOrigin = $v.catalogOrigin?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
          other) {
    _$v = other
        as _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload;
  }

  @override
  void update(
      void Function(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      build() => _build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      _build() {
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
        _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
              ._(
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload',
                'name'),
            exercises: exercises.build(),
            catalogOrigin: _catalogOrigin?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload',
                'updatedAt'),
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
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload',
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
