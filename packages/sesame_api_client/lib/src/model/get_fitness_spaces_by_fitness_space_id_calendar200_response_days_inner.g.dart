// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner
    extends GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner {
  @override
  final String date;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>
      workouts;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>
      restDays;

  factory _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner._(
      {required this.date, required this.workouts, required this.restDays})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner &&
        date == other.date &&
        workouts == other.workouts &&
        restDays == other.restDays;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, workouts.hashCode);
    _$hash = $jc(_$hash, restDays.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner')
          ..add('date', date)
          ..add('workouts', workouts)
          ..add('restDays', restDays))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>?
      _workouts;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>
      get workouts => _$this._workouts ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>();
  set workouts(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>?
              workouts) =>
      _$this._workouts = workouts;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>?
      _restDays;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>
      get restDays => _$this._restDays ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>();
  set restDays(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>?
              restDays) =>
      _$this._restDays = restDays;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _workouts = $v.workouts.toBuilder();
      _restDays = $v.restDays.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner other) {
    _$v =
        other as _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner _build() {
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner._(
            date: BuiltValueNullFieldError.checkNotNull(
                date,
                r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner',
                'date'),
            workouts: workouts.build(),
            restDays: restDays.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'workouts';
        workouts.build();
        _$failedField = 'restDays';
        restDays.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner',
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
