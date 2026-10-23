// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_calendar200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response
    extends GetFitnessSpacesByFitnessSpaceIdCalendar200Response {
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>
      days;

  factory _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response._({required this.days})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdCalendar200Response &&
        days == other.days;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200Response')
          ..add('days', days))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdCalendar200Response,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response? _$v;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>?
      _days;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>
      get days => _$this._days ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>();
  set days(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>?
              days) =>
      _$this._days = days;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdCalendar200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _days = $v.days.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdCalendar200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response;
  }

  @override
  void update(
      void Function(GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response._(
            days: days.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'days';
        days.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200Response',
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
