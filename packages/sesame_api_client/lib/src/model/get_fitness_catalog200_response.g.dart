// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_catalog200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessCatalog200Response extends GetFitnessCatalog200Response {
  @override
  final int schemaVersion;
  @override
  final int contentVersion;
  @override
  final BuiltList<GetFitnessCatalog200ResponseExercisesInner> exercises;
  @override
  final GetFitnessCatalog200ResponseTaxonomies? taxonomies;

  factory _$GetFitnessCatalog200Response(
          [void Function(GetFitnessCatalog200ResponseBuilder)? updates]) =>
      (GetFitnessCatalog200ResponseBuilder()..update(updates))._build();

  _$GetFitnessCatalog200Response._(
      {required this.schemaVersion,
      required this.contentVersion,
      required this.exercises,
      this.taxonomies})
      : super._();
  @override
  GetFitnessCatalog200Response rebuild(
          void Function(GetFitnessCatalog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessCatalog200ResponseBuilder toBuilder() =>
      GetFitnessCatalog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessCatalog200Response &&
        schemaVersion == other.schemaVersion &&
        contentVersion == other.contentVersion &&
        exercises == other.exercises &&
        taxonomies == other.taxonomies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, contentVersion.hashCode);
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jc(_$hash, taxonomies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetFitnessCatalog200Response')
          ..add('schemaVersion', schemaVersion)
          ..add('contentVersion', contentVersion)
          ..add('exercises', exercises)
          ..add('taxonomies', taxonomies))
        .toString();
  }
}

class GetFitnessCatalog200ResponseBuilder
    implements
        Builder<GetFitnessCatalog200Response,
            GetFitnessCatalog200ResponseBuilder> {
  _$GetFitnessCatalog200Response? _$v;

  int? _schemaVersion;
  int? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(int? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  int? _contentVersion;
  int? get contentVersion => _$this._contentVersion;
  set contentVersion(int? contentVersion) =>
      _$this._contentVersion = contentVersion;

  ListBuilder<GetFitnessCatalog200ResponseExercisesInner>? _exercises;
  ListBuilder<GetFitnessCatalog200ResponseExercisesInner> get exercises =>
      _$this._exercises ??=
          ListBuilder<GetFitnessCatalog200ResponseExercisesInner>();
  set exercises(
          ListBuilder<GetFitnessCatalog200ResponseExercisesInner>? exercises) =>
      _$this._exercises = exercises;

  GetFitnessCatalog200ResponseTaxonomiesBuilder? _taxonomies;
  GetFitnessCatalog200ResponseTaxonomiesBuilder get taxonomies =>
      _$this._taxonomies ??= GetFitnessCatalog200ResponseTaxonomiesBuilder();
  set taxonomies(GetFitnessCatalog200ResponseTaxonomiesBuilder? taxonomies) =>
      _$this._taxonomies = taxonomies;

  GetFitnessCatalog200ResponseBuilder() {
    GetFitnessCatalog200Response._defaults(this);
  }

  GetFitnessCatalog200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _schemaVersion = $v.schemaVersion;
      _contentVersion = $v.contentVersion;
      _exercises = $v.exercises.toBuilder();
      _taxonomies = $v.taxonomies?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessCatalog200Response other) {
    _$v = other as _$GetFitnessCatalog200Response;
  }

  @override
  void update(void Function(GetFitnessCatalog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessCatalog200Response build() => _build();

  _$GetFitnessCatalog200Response _build() {
    _$GetFitnessCatalog200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessCatalog200Response._(
            schemaVersion: BuiltValueNullFieldError.checkNotNull(schemaVersion,
                r'GetFitnessCatalog200Response', 'schemaVersion'),
            contentVersion: BuiltValueNullFieldError.checkNotNull(
                contentVersion,
                r'GetFitnessCatalog200Response',
                'contentVersion'),
            exercises: exercises.build(),
            taxonomies: _taxonomies?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exercises';
        exercises.build();
        _$failedField = 'taxonomies';
        _taxonomies?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessCatalog200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
