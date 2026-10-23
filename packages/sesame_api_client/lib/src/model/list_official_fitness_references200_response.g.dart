// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_fitness_references200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListOfficialFitnessReferences200Response
    extends ListOfficialFitnessReferences200Response {
  @override
  final BuiltList<ListOfficialFitnessReferences200ResponseExercisesInner>
      exercises;
  @override
  final BuiltList<ListOfficialFitnessReferences200ResponseExercisesInner>
      templates;

  factory _$ListOfficialFitnessReferences200Response(
          [void Function(ListOfficialFitnessReferences200ResponseBuilder)?
              updates]) =>
      (ListOfficialFitnessReferences200ResponseBuilder()..update(updates))
          ._build();

  _$ListOfficialFitnessReferences200Response._(
      {required this.exercises, required this.templates})
      : super._();
  @override
  ListOfficialFitnessReferences200Response rebuild(
          void Function(ListOfficialFitnessReferences200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialFitnessReferences200ResponseBuilder toBuilder() =>
      ListOfficialFitnessReferences200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialFitnessReferences200Response &&
        exercises == other.exercises &&
        templates == other.templates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jc(_$hash, templates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListOfficialFitnessReferences200Response')
          ..add('exercises', exercises)
          ..add('templates', templates))
        .toString();
  }
}

class ListOfficialFitnessReferences200ResponseBuilder
    implements
        Builder<ListOfficialFitnessReferences200Response,
            ListOfficialFitnessReferences200ResponseBuilder> {
  _$ListOfficialFitnessReferences200Response? _$v;

  ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>?
      _exercises;
  ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>
      get exercises => _$this._exercises ??=
          ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>();
  set exercises(
          ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>?
              exercises) =>
      _$this._exercises = exercises;

  ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>?
      _templates;
  ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>
      get templates => _$this._templates ??=
          ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>();
  set templates(
          ListBuilder<ListOfficialFitnessReferences200ResponseExercisesInner>?
              templates) =>
      _$this._templates = templates;

  ListOfficialFitnessReferences200ResponseBuilder() {
    ListOfficialFitnessReferences200Response._defaults(this);
  }

  ListOfficialFitnessReferences200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exercises = $v.exercises.toBuilder();
      _templates = $v.templates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialFitnessReferences200Response other) {
    _$v = other as _$ListOfficialFitnessReferences200Response;
  }

  @override
  void update(
      void Function(ListOfficialFitnessReferences200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialFitnessReferences200Response build() => _build();

  _$ListOfficialFitnessReferences200Response _build() {
    _$ListOfficialFitnessReferences200Response _$result;
    try {
      _$result = _$v ??
          _$ListOfficialFitnessReferences200Response._(
            exercises: exercises.build(),
            templates: templates.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exercises';
        exercises.build();
        _$failedField = 'templates';
        templates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialFitnessReferences200Response',
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
