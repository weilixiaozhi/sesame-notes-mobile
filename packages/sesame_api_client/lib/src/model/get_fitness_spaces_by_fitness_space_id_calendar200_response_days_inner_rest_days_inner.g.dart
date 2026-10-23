// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_rest_days_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
    extends GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner {
  @override
  final String sourcePlanId;
  @override
  final String sourcePlanName;

  factory _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner._(
      {required this.sourcePlanId, required this.sourcePlanName})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner &&
        sourcePlanId == other.sourcePlanId &&
        sourcePlanName == other.sourcePlanName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourcePlanId.hashCode);
    _$hash = $jc(_$hash, sourcePlanName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner')
          ..add('sourcePlanId', sourcePlanId)
          ..add('sourcePlanName', sourcePlanName))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner?
      _$v;

  String? _sourcePlanId;
  String? get sourcePlanId => _$this._sourcePlanId;
  set sourcePlanId(String? sourcePlanId) => _$this._sourcePlanId = sourcePlanId;

  String? _sourcePlanName;
  String? get sourcePlanName => _$this._sourcePlanName;
  set sourcePlanName(String? sourcePlanName) =>
      _$this._sourcePlanName = sourcePlanName;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourcePlanId = $v.sourcePlanId;
      _sourcePlanName = $v.sourcePlanName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
            ._(
          sourcePlanId: BuiltValueNullFieldError.checkNotNull(
              sourcePlanId,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner',
              'sourcePlanId'),
          sourcePlanName: BuiltValueNullFieldError.checkNotNull(
              sourcePlanName,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner',
              'sourcePlanName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
