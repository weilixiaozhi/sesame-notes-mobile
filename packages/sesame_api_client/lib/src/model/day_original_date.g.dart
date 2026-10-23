// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_original_date.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DayOriginalDateCalendarTypeEnum _$dayOriginalDateCalendarTypeEnum_solar =
    const DayOriginalDateCalendarTypeEnum._('solar');
const DayOriginalDateCalendarTypeEnum _$dayOriginalDateCalendarTypeEnum_lunar =
    const DayOriginalDateCalendarTypeEnum._('lunar');

DayOriginalDateCalendarTypeEnum _$dayOriginalDateCalendarTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'solar':
      return _$dayOriginalDateCalendarTypeEnum_solar;
    case 'lunar':
      return _$dayOriginalDateCalendarTypeEnum_lunar;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DayOriginalDateCalendarTypeEnum>
    _$dayOriginalDateCalendarTypeEnumValues = BuiltSet<
        DayOriginalDateCalendarTypeEnum>(const <DayOriginalDateCalendarTypeEnum>[
  _$dayOriginalDateCalendarTypeEnum_solar,
  _$dayOriginalDateCalendarTypeEnum_lunar,
]);

Serializer<DayOriginalDateCalendarTypeEnum>
    _$dayOriginalDateCalendarTypeEnumSerializer =
    _$DayOriginalDateCalendarTypeEnumSerializer();

class _$DayOriginalDateCalendarTypeEnumSerializer
    implements PrimitiveSerializer<DayOriginalDateCalendarTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'solar': 'solar',
    'lunar': 'lunar',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'solar': 'solar',
    'lunar': 'lunar',
  };

  @override
  final Iterable<Type> types = const <Type>[DayOriginalDateCalendarTypeEnum];
  @override
  final String wireName = 'DayOriginalDateCalendarTypeEnum';

  @override
  Object serialize(
          Serializers serializers, DayOriginalDateCalendarTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DayOriginalDateCalendarTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DayOriginalDateCalendarTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DayOriginalDate extends DayOriginalDate {
  @override
  final DayOriginalDateCalendarTypeEnum calendarType;
  @override
  final int originalYear;
  @override
  final int originalMonth;
  @override
  final int originalDay;
  @override
  final bool isLeapMonth;
  @override
  final String solarDate;

  factory _$DayOriginalDate([void Function(DayOriginalDateBuilder)? updates]) =>
      (DayOriginalDateBuilder()..update(updates))._build();

  _$DayOriginalDate._(
      {required this.calendarType,
      required this.originalYear,
      required this.originalMonth,
      required this.originalDay,
      required this.isLeapMonth,
      required this.solarDate})
      : super._();
  @override
  DayOriginalDate rebuild(void Function(DayOriginalDateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DayOriginalDateBuilder toBuilder() => DayOriginalDateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DayOriginalDate &&
        calendarType == other.calendarType &&
        originalYear == other.originalYear &&
        originalMonth == other.originalMonth &&
        originalDay == other.originalDay &&
        isLeapMonth == other.isLeapMonth &&
        solarDate == other.solarDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, calendarType.hashCode);
    _$hash = $jc(_$hash, originalYear.hashCode);
    _$hash = $jc(_$hash, originalMonth.hashCode);
    _$hash = $jc(_$hash, originalDay.hashCode);
    _$hash = $jc(_$hash, isLeapMonth.hashCode);
    _$hash = $jc(_$hash, solarDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DayOriginalDate')
          ..add('calendarType', calendarType)
          ..add('originalYear', originalYear)
          ..add('originalMonth', originalMonth)
          ..add('originalDay', originalDay)
          ..add('isLeapMonth', isLeapMonth)
          ..add('solarDate', solarDate))
        .toString();
  }
}

class DayOriginalDateBuilder
    implements Builder<DayOriginalDate, DayOriginalDateBuilder> {
  _$DayOriginalDate? _$v;

  DayOriginalDateCalendarTypeEnum? _calendarType;
  DayOriginalDateCalendarTypeEnum? get calendarType => _$this._calendarType;
  set calendarType(DayOriginalDateCalendarTypeEnum? calendarType) =>
      _$this._calendarType = calendarType;

  int? _originalYear;
  int? get originalYear => _$this._originalYear;
  set originalYear(int? originalYear) => _$this._originalYear = originalYear;

  int? _originalMonth;
  int? get originalMonth => _$this._originalMonth;
  set originalMonth(int? originalMonth) =>
      _$this._originalMonth = originalMonth;

  int? _originalDay;
  int? get originalDay => _$this._originalDay;
  set originalDay(int? originalDay) => _$this._originalDay = originalDay;

  bool? _isLeapMonth;
  bool? get isLeapMonth => _$this._isLeapMonth;
  set isLeapMonth(bool? isLeapMonth) => _$this._isLeapMonth = isLeapMonth;

  String? _solarDate;
  String? get solarDate => _$this._solarDate;
  set solarDate(String? solarDate) => _$this._solarDate = solarDate;

  DayOriginalDateBuilder() {
    DayOriginalDate._defaults(this);
  }

  DayOriginalDateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _calendarType = $v.calendarType;
      _originalYear = $v.originalYear;
      _originalMonth = $v.originalMonth;
      _originalDay = $v.originalDay;
      _isLeapMonth = $v.isLeapMonth;
      _solarDate = $v.solarDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DayOriginalDate other) {
    _$v = other as _$DayOriginalDate;
  }

  @override
  void update(void Function(DayOriginalDateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DayOriginalDate build() => _build();

  _$DayOriginalDate _build() {
    final _$result = _$v ??
        _$DayOriginalDate._(
          calendarType: BuiltValueNullFieldError.checkNotNull(
              calendarType, r'DayOriginalDate', 'calendarType'),
          originalYear: BuiltValueNullFieldError.checkNotNull(
              originalYear, r'DayOriginalDate', 'originalYear'),
          originalMonth: BuiltValueNullFieldError.checkNotNull(
              originalMonth, r'DayOriginalDate', 'originalMonth'),
          originalDay: BuiltValueNullFieldError.checkNotNull(
              originalDay, r'DayOriginalDate', 'originalDay'),
          isLeapMonth: BuiltValueNullFieldError.checkNotNull(
              isLeapMonth, r'DayOriginalDate', 'isLeapMonth'),
          solarDate: BuiltValueNullFieldError.checkNotNull(
              solarDate, r'DayOriginalDate', 'solarDate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
