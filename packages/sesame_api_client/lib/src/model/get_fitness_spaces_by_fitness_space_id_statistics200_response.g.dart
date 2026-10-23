// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_statistics200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response
    extends GetFitnessSpacesByFitnessSpaceIdStatistics200Response {
  @override
  final int trainingDays;
  @override
  final int completedWorkouts;
  @override
  final int completedSets;
  @override
  final int totalDurationMs;
  @override
  final String volumeKg;
  @override
  final BuiltList<
      GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner> byDate;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>
      byExercise;

  factory _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response._(
      {required this.trainingDays,
      required this.completedWorkouts,
      required this.completedSets,
      required this.totalDurationMs,
      required this.volumeKg,
      required this.byDate,
      required this.byExercise})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdStatistics200Response &&
        trainingDays == other.trainingDays &&
        completedWorkouts == other.completedWorkouts &&
        completedSets == other.completedSets &&
        totalDurationMs == other.totalDurationMs &&
        volumeKg == other.volumeKg &&
        byDate == other.byDate &&
        byExercise == other.byExercise;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trainingDays.hashCode);
    _$hash = $jc(_$hash, completedWorkouts.hashCode);
    _$hash = $jc(_$hash, completedSets.hashCode);
    _$hash = $jc(_$hash, totalDurationMs.hashCode);
    _$hash = $jc(_$hash, volumeKg.hashCode);
    _$hash = $jc(_$hash, byDate.hashCode);
    _$hash = $jc(_$hash, byExercise.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response')
          ..add('trainingDays', trainingDays)
          ..add('completedWorkouts', completedWorkouts)
          ..add('completedSets', completedSets)
          ..add('totalDurationMs', totalDurationMs)
          ..add('volumeKg', volumeKg)
          ..add('byDate', byDate)
          ..add('byExercise', byExercise))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdStatistics200Response,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response? _$v;

  int? _trainingDays;
  int? get trainingDays => _$this._trainingDays;
  set trainingDays(int? trainingDays) => _$this._trainingDays = trainingDays;

  int? _completedWorkouts;
  int? get completedWorkouts => _$this._completedWorkouts;
  set completedWorkouts(int? completedWorkouts) =>
      _$this._completedWorkouts = completedWorkouts;

  int? _completedSets;
  int? get completedSets => _$this._completedSets;
  set completedSets(int? completedSets) =>
      _$this._completedSets = completedSets;

  int? _totalDurationMs;
  int? get totalDurationMs => _$this._totalDurationMs;
  set totalDurationMs(int? totalDurationMs) =>
      _$this._totalDurationMs = totalDurationMs;

  String? _volumeKg;
  String? get volumeKg => _$this._volumeKg;
  set volumeKg(String? volumeKg) => _$this._volumeKg = volumeKg;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>?
      _byDate;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>
      get byDate => _$this._byDate ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>();
  set byDate(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>?
              byDate) =>
      _$this._byDate = byDate;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>?
      _byExercise;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>
      get byExercise => _$this._byExercise ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>();
  set byExercise(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>?
              byExercise) =>
      _$this._byExercise = byExercise;

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdStatistics200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trainingDays = $v.trainingDays;
      _completedWorkouts = $v.completedWorkouts;
      _completedSets = $v.completedSets;
      _totalDurationMs = $v.totalDurationMs;
      _volumeKg = $v.volumeKg;
      _byDate = $v.byDate.toBuilder();
      _byExercise = $v.byExercise.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdStatistics200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response._(
            trainingDays: BuiltValueNullFieldError.checkNotNull(
                trainingDays,
                r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
                'trainingDays'),
            completedWorkouts: BuiltValueNullFieldError.checkNotNull(
                completedWorkouts,
                r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
                'completedWorkouts'),
            completedSets: BuiltValueNullFieldError.checkNotNull(
                completedSets,
                r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
                'completedSets'),
            totalDurationMs: BuiltValueNullFieldError.checkNotNull(
                totalDurationMs,
                r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
                'totalDurationMs'),
            volumeKg: BuiltValueNullFieldError.checkNotNull(
                volumeKg,
                r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
                'volumeKg'),
            byDate: byDate.build(),
            byExercise: byExercise.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'byDate';
        byDate.build();
        _$failedField = 'byExercise';
        byExercise.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response',
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
