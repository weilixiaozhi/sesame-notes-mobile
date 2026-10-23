// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
    extends GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner {
  @override
  final String id;
  @override
  final String exerciseId;
  @override
  final int restSeconds;
  @override
  final int? warmupRestSeconds;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>
      sets;

  factory _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner._(
      {required this.id,
      required this.exerciseId,
      required this.restSeconds,
      this.warmupRestSeconds,
      required this.sets})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner &&
        id == other.id &&
        exerciseId == other.exerciseId &&
        restSeconds == other.restSeconds &&
        warmupRestSeconds == other.warmupRestSeconds &&
        sets == other.sets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, exerciseId.hashCode);
    _$hash = $jc(_$hash, restSeconds.hashCode);
    _$hash = $jc(_$hash, warmupRestSeconds.hashCode);
    _$hash = $jc(_$hash, sets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner')
          ..add('id', id)
          ..add('exerciseId', exerciseId)
          ..add('restSeconds', restSeconds)
          ..add('warmupRestSeconds', warmupRestSeconds)
          ..add('sets', sets))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _exerciseId;
  String? get exerciseId => _$this._exerciseId;
  set exerciseId(String? exerciseId) => _$this._exerciseId = exerciseId;

  int? _restSeconds;
  int? get restSeconds => _$this._restSeconds;
  set restSeconds(int? restSeconds) => _$this._restSeconds = restSeconds;

  int? _warmupRestSeconds;
  int? get warmupRestSeconds => _$this._warmupRestSeconds;
  set warmupRestSeconds(int? warmupRestSeconds) =>
      _$this._warmupRestSeconds = warmupRestSeconds;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>?
      _sets;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>
      get sets => _$this._sets ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>();
  set sets(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>?
              sets) =>
      _$this._sets = sets;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _exerciseId = $v.exerciseId;
      _restSeconds = $v.restSeconds;
      _warmupRestSeconds = $v.warmupRestSeconds;
      _sets = $v.sets.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner',
                'id'),
            exerciseId: BuiltValueNullFieldError.checkNotNull(
                exerciseId,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner',
                'exerciseId'),
            restSeconds: BuiltValueNullFieldError.checkNotNull(
                restSeconds,
                r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner',
                'restSeconds'),
            warmupRestSeconds: warmupRestSeconds,
            sets: sets.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sets';
        sets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner',
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
