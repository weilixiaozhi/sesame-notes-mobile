// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_statistics200_response_by_exercise_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
    extends GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner {
  @override
  final String exerciseId;
  @override
  final int completedSets;
  @override
  final int workingSets;
  @override
  final String volumeKg;

  factory _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner._(
      {required this.exerciseId,
      required this.completedSets,
      required this.workingSets,
      required this.volumeKg})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner &&
        exerciseId == other.exerciseId &&
        completedSets == other.completedSets &&
        workingSets == other.workingSets &&
        volumeKg == other.volumeKg;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exerciseId.hashCode);
    _$hash = $jc(_$hash, completedSets.hashCode);
    _$hash = $jc(_$hash, workingSets.hashCode);
    _$hash = $jc(_$hash, volumeKg.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner')
          ..add('exerciseId', exerciseId)
          ..add('completedSets', completedSets)
          ..add('workingSets', workingSets)
          ..add('volumeKg', volumeKg))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner? _$v;

  String? _exerciseId;
  String? get exerciseId => _$this._exerciseId;
  set exerciseId(String? exerciseId) => _$this._exerciseId = exerciseId;

  int? _completedSets;
  int? get completedSets => _$this._completedSets;
  set completedSets(int? completedSets) =>
      _$this._completedSets = completedSets;

  int? _workingSets;
  int? get workingSets => _$this._workingSets;
  set workingSets(int? workingSets) => _$this._workingSets = workingSets;

  String? _volumeKg;
  String? get volumeKg => _$this._volumeKg;
  set volumeKg(String? volumeKg) => _$this._volumeKg = volumeKg;

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _exerciseId = $v.exerciseId;
      _completedSets = $v.completedSets;
      _workingSets = $v.workingSets;
      _volumeKg = $v.volumeKg;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
            ._(
          exerciseId: BuiltValueNullFieldError.checkNotNull(
              exerciseId,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner',
              'exerciseId'),
          completedSets: BuiltValueNullFieldError.checkNotNull(
              completedSets,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner',
              'completedSets'),
          workingSets: BuiltValueNullFieldError.checkNotNull(
              workingSets,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner',
              'workingSets'),
          volumeKg: BuiltValueNullFieldError.checkNotNull(
              volumeKg,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner',
              'volumeKg'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
