// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_banner_statistics200_response_range.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminBannerStatistics200ResponseRangeTimezoneEnum
    _$getAdminBannerStatistics200ResponseRangeTimezoneEnum_asiaSlashShanghai =
    const GetAdminBannerStatistics200ResponseRangeTimezoneEnum._(
        'asiaSlashShanghai');

GetAdminBannerStatistics200ResponseRangeTimezoneEnum
    _$getAdminBannerStatistics200ResponseRangeTimezoneEnumValueOf(String name) {
  switch (name) {
    case 'asiaSlashShanghai':
      return _$getAdminBannerStatistics200ResponseRangeTimezoneEnum_asiaSlashShanghai;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminBannerStatistics200ResponseRangeTimezoneEnum>
    _$getAdminBannerStatistics200ResponseRangeTimezoneEnumValues = BuiltSet<
        GetAdminBannerStatistics200ResponseRangeTimezoneEnum>(const <GetAdminBannerStatistics200ResponseRangeTimezoneEnum>[
  _$getAdminBannerStatistics200ResponseRangeTimezoneEnum_asiaSlashShanghai,
]);

Serializer<GetAdminBannerStatistics200ResponseRangeTimezoneEnum>
    _$getAdminBannerStatistics200ResponseRangeTimezoneEnumSerializer =
    _$GetAdminBannerStatistics200ResponseRangeTimezoneEnumSerializer();

class _$GetAdminBannerStatistics200ResponseRangeTimezoneEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminBannerStatistics200ResponseRangeTimezoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'asiaSlashShanghai': 'Asia/Shanghai',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Asia/Shanghai': 'asiaSlashShanghai',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminBannerStatistics200ResponseRangeTimezoneEnum
  ];
  @override
  final String wireName =
      'GetAdminBannerStatistics200ResponseRangeTimezoneEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminBannerStatistics200ResponseRangeTimezoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminBannerStatistics200ResponseRangeTimezoneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminBannerStatistics200ResponseRangeTimezoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminBannerStatistics200ResponseRange
    extends GetAdminBannerStatistics200ResponseRange {
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final GetAdminBannerStatistics200ResponseRangeTimezoneEnum timezone;

  factory _$GetAdminBannerStatistics200ResponseRange(
          [void Function(GetAdminBannerStatistics200ResponseRangeBuilder)?
              updates]) =>
      (GetAdminBannerStatistics200ResponseRangeBuilder()..update(updates))
          ._build();

  _$GetAdminBannerStatistics200ResponseRange._(
      {required this.startDate, required this.endDate, required this.timezone})
      : super._();
  @override
  GetAdminBannerStatistics200ResponseRange rebuild(
          void Function(GetAdminBannerStatistics200ResponseRangeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminBannerStatistics200ResponseRangeBuilder toBuilder() =>
      GetAdminBannerStatistics200ResponseRangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminBannerStatistics200ResponseRange &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminBannerStatistics200ResponseRange')
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('timezone', timezone))
        .toString();
  }
}

class GetAdminBannerStatistics200ResponseRangeBuilder
    implements
        Builder<GetAdminBannerStatistics200ResponseRange,
            GetAdminBannerStatistics200ResponseRangeBuilder> {
  _$GetAdminBannerStatistics200ResponseRange? _$v;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  String? _endDate;
  String? get endDate => _$this._endDate;
  set endDate(String? endDate) => _$this._endDate = endDate;

  GetAdminBannerStatistics200ResponseRangeTimezoneEnum? _timezone;
  GetAdminBannerStatistics200ResponseRangeTimezoneEnum? get timezone =>
      _$this._timezone;
  set timezone(
          GetAdminBannerStatistics200ResponseRangeTimezoneEnum? timezone) =>
      _$this._timezone = timezone;

  GetAdminBannerStatistics200ResponseRangeBuilder() {
    GetAdminBannerStatistics200ResponseRange._defaults(this);
  }

  GetAdminBannerStatistics200ResponseRangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminBannerStatistics200ResponseRange other) {
    _$v = other as _$GetAdminBannerStatistics200ResponseRange;
  }

  @override
  void update(
      void Function(GetAdminBannerStatistics200ResponseRangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminBannerStatistics200ResponseRange build() => _build();

  _$GetAdminBannerStatistics200ResponseRange _build() {
    final _$result = _$v ??
        _$GetAdminBannerStatistics200ResponseRange._(
          startDate: BuiltValueNullFieldError.checkNotNull(startDate,
              r'GetAdminBannerStatistics200ResponseRange', 'startDate'),
          endDate: BuiltValueNullFieldError.checkNotNull(
              endDate, r'GetAdminBannerStatistics200ResponseRange', 'endDate'),
          timezone: BuiltValueNullFieldError.checkNotNull(timezone,
              r'GetAdminBannerStatistics200ResponseRange', 'timezone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
