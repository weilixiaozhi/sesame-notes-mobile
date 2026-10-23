// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_statistics200_response_by_date_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner
    extends GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner {
  @override
  final String date;
  @override
  final int completedWorkouts;
  @override
  final int completedSets;
  @override
  final int durationMs;
  @override
  final String volumeKg;

  factory _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner._(
      {required this.date,
      required this.completedWorkouts,
      required this.completedSets,
      required this.durationMs,
      required this.volumeKg})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner &&
        date == other.date &&
        completedWorkouts == other.completedWorkouts &&
        completedSets == other.completedSets &&
        durationMs == other.durationMs &&
        volumeKg == other.volumeKg;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, completedWorkouts.hashCode);
    _$hash = $jc(_$hash, completedSets.hashCode);
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jc(_$hash, volumeKg.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner')
          ..add('date', date)
          ..add('completedWorkouts', completedWorkouts)
          ..add('completedSets', completedSets)
          ..add('durationMs', durationMs)
          ..add('volumeKg', volumeKg))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  int? _completedWorkouts;
  int? get completedWorkouts => _$this._completedWorkouts;
  set completedWorkouts(int? completedWorkouts) =>
      _$this._completedWorkouts = completedWorkouts;

  int? _completedSets;
  int? get completedSets => _$this._completedSets;
  set completedSets(int? completedSets) =>
      _$this._completedSets = completedSets;

  int? _durationMs;
  int? get durationMs => _$this._durationMs;
  set durationMs(int? durationMs) => _$this._durationMs = durationMs;

  String? _volumeKg;
  String? get volumeKg => _$this._volumeKg;
  set volumeKg(String? volumeKg) => _$this._volumeKg = volumeKg;

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _completedWorkouts = $v.completedWorkouts;
      _completedSets = $v.completedSets;
      _durationMs = $v.durationMs;
      _volumeKg = $v.volumeKg;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner._(
          date: BuiltValueNullFieldError.checkNotNull(
              date,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner',
              'date'),
          completedWorkouts: BuiltValueNullFieldError.checkNotNull(
              completedWorkouts,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner',
              'completedWorkouts'),
          completedSets: BuiltValueNullFieldError.checkNotNull(
              completedSets,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner',
              'completedSets'),
          durationMs: BuiltValueNullFieldError.checkNotNull(
              durationMs,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner',
              'durationMs'),
          volumeKg: BuiltValueNullFieldError.checkNotNull(
              volumeKg,
              r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner',
              'volumeKg'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
