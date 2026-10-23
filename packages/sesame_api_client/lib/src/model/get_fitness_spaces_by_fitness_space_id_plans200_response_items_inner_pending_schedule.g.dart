// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_pending_schedule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule {
  @override
  final int cycleDays;
  @override
  final BuiltList<
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner> days;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule._(
      {required this.cycleDays, required this.days})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule &&
        cycleDays == other.cycleDays &&
        days == other.days;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cycleDays.hashCode);
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule')
          ..add('cycleDays', cycleDays)
          ..add('days', days))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule?
      _$v;

  int? _cycleDays;
  int? get cycleDays => _$this._cycleDays;
  set cycleDays(int? cycleDays) => _$this._cycleDays = cycleDays;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>?
      _days;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>
      get days => _$this._days ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>();
  set days(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>?
              days) =>
      _$this._days = days;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _cycleDays = $v.cycleDays;
      _days = $v.days.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
              ._(
            cycleDays: BuiltValueNullFieldError.checkNotNull(
                cycleDays,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule',
                'cycleDays'),
            days: days.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'days';
        days.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule',
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
