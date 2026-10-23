// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner {
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
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>
      sets;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner._(
      {required this.id,
      required this.exerciseId,
      required this.restSeconds,
      this.warmupRestSeconds,
      required this.sets})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner &&
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
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner')
          ..add('id', id)
          ..add('exerciseId', exerciseId)
          ..add('restSeconds', restSeconds)
          ..add('warmupRestSeconds', warmupRestSeconds)
          ..add('sets', sets))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner?
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
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>?
      _sets;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>
      get sets => _$this._sets ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>();
  set sets(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>?
              sets) =>
      _$this._sets = sets;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
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
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner',
                'id'),
            exerciseId: BuiltValueNullFieldError.checkNotNull(
                exerciseId,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner',
                'exerciseId'),
            restSeconds: BuiltValueNullFieldError.checkNotNull(
                restSeconds,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner',
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
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner',
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
