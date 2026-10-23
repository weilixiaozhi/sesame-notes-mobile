// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics200_response_range.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminAnalytics200ResponseRangeTimezoneEnum
    _$getAdminAnalytics200ResponseRangeTimezoneEnum_asiaSlashShanghai =
    const GetAdminAnalytics200ResponseRangeTimezoneEnum._('asiaSlashShanghai');

GetAdminAnalytics200ResponseRangeTimezoneEnum
    _$getAdminAnalytics200ResponseRangeTimezoneEnumValueOf(String name) {
  switch (name) {
    case 'asiaSlashShanghai':
      return _$getAdminAnalytics200ResponseRangeTimezoneEnum_asiaSlashShanghai;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalytics200ResponseRangeTimezoneEnum>
    _$getAdminAnalytics200ResponseRangeTimezoneEnumValues = BuiltSet<
        GetAdminAnalytics200ResponseRangeTimezoneEnum>(const <GetAdminAnalytics200ResponseRangeTimezoneEnum>[
  _$getAdminAnalytics200ResponseRangeTimezoneEnum_asiaSlashShanghai,
]);

const GetAdminAnalytics200ResponseRangePlatformEnum
    _$getAdminAnalytics200ResponseRangePlatformEnum_all =
    const GetAdminAnalytics200ResponseRangePlatformEnum._('all');
const GetAdminAnalytics200ResponseRangePlatformEnum
    _$getAdminAnalytics200ResponseRangePlatformEnum_app =
    const GetAdminAnalytics200ResponseRangePlatformEnum._('app');
const GetAdminAnalytics200ResponseRangePlatformEnum
    _$getAdminAnalytics200ResponseRangePlatformEnum_web =
    const GetAdminAnalytics200ResponseRangePlatformEnum._('web');

GetAdminAnalytics200ResponseRangePlatformEnum
    _$getAdminAnalytics200ResponseRangePlatformEnumValueOf(String name) {
  switch (name) {
    case 'all':
      return _$getAdminAnalytics200ResponseRangePlatformEnum_all;
    case 'app':
      return _$getAdminAnalytics200ResponseRangePlatformEnum_app;
    case 'web':
      return _$getAdminAnalytics200ResponseRangePlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalytics200ResponseRangePlatformEnum>
    _$getAdminAnalytics200ResponseRangePlatformEnumValues = BuiltSet<
        GetAdminAnalytics200ResponseRangePlatformEnum>(const <GetAdminAnalytics200ResponseRangePlatformEnum>[
  _$getAdminAnalytics200ResponseRangePlatformEnum_all,
  _$getAdminAnalytics200ResponseRangePlatformEnum_app,
  _$getAdminAnalytics200ResponseRangePlatformEnum_web,
]);

const GetAdminAnalytics200ResponseRangeBucketEnum
    _$getAdminAnalytics200ResponseRangeBucketEnum_hour =
    const GetAdminAnalytics200ResponseRangeBucketEnum._('hour');
const GetAdminAnalytics200ResponseRangeBucketEnum
    _$getAdminAnalytics200ResponseRangeBucketEnum_day =
    const GetAdminAnalytics200ResponseRangeBucketEnum._('day');
const GetAdminAnalytics200ResponseRangeBucketEnum
    _$getAdminAnalytics200ResponseRangeBucketEnum_month =
    const GetAdminAnalytics200ResponseRangeBucketEnum._('month');

GetAdminAnalytics200ResponseRangeBucketEnum
    _$getAdminAnalytics200ResponseRangeBucketEnumValueOf(String name) {
  switch (name) {
    case 'hour':
      return _$getAdminAnalytics200ResponseRangeBucketEnum_hour;
    case 'day':
      return _$getAdminAnalytics200ResponseRangeBucketEnum_day;
    case 'month':
      return _$getAdminAnalytics200ResponseRangeBucketEnum_month;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalytics200ResponseRangeBucketEnum>
    _$getAdminAnalytics200ResponseRangeBucketEnumValues = BuiltSet<
        GetAdminAnalytics200ResponseRangeBucketEnum>(const <GetAdminAnalytics200ResponseRangeBucketEnum>[
  _$getAdminAnalytics200ResponseRangeBucketEnum_hour,
  _$getAdminAnalytics200ResponseRangeBucketEnum_day,
  _$getAdminAnalytics200ResponseRangeBucketEnum_month,
]);

Serializer<GetAdminAnalytics200ResponseRangeTimezoneEnum>
    _$getAdminAnalytics200ResponseRangeTimezoneEnumSerializer =
    _$GetAdminAnalytics200ResponseRangeTimezoneEnumSerializer();
Serializer<GetAdminAnalytics200ResponseRangePlatformEnum>
    _$getAdminAnalytics200ResponseRangePlatformEnumSerializer =
    _$GetAdminAnalytics200ResponseRangePlatformEnumSerializer();
Serializer<GetAdminAnalytics200ResponseRangeBucketEnum>
    _$getAdminAnalytics200ResponseRangeBucketEnumSerializer =
    _$GetAdminAnalytics200ResponseRangeBucketEnumSerializer();

class _$GetAdminAnalytics200ResponseRangeTimezoneEnumSerializer
    implements
        PrimitiveSerializer<GetAdminAnalytics200ResponseRangeTimezoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'asiaSlashShanghai': 'Asia/Shanghai',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Asia/Shanghai': 'asiaSlashShanghai',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalytics200ResponseRangeTimezoneEnum
  ];
  @override
  final String wireName = 'GetAdminAnalytics200ResponseRangeTimezoneEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalytics200ResponseRangeTimezoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalytics200ResponseRangeTimezoneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalytics200ResponseRangeTimezoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalytics200ResponseRangePlatformEnumSerializer
    implements
        PrimitiveSerializer<GetAdminAnalytics200ResponseRangePlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'all': 'all',
    'app': 'app',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'all': 'all',
    'app': 'app',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalytics200ResponseRangePlatformEnum
  ];
  @override
  final String wireName = 'GetAdminAnalytics200ResponseRangePlatformEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalytics200ResponseRangePlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalytics200ResponseRangePlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalytics200ResponseRangePlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalytics200ResponseRangeBucketEnumSerializer
    implements
        PrimitiveSerializer<GetAdminAnalytics200ResponseRangeBucketEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'hour': 'hour',
    'day': 'day',
    'month': 'month',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'hour': 'hour',
    'day': 'day',
    'month': 'month',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalytics200ResponseRangeBucketEnum
  ];
  @override
  final String wireName = 'GetAdminAnalytics200ResponseRangeBucketEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalytics200ResponseRangeBucketEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalytics200ResponseRangeBucketEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalytics200ResponseRangeBucketEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalytics200ResponseRange
    extends GetAdminAnalytics200ResponseRange {
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final GetAdminAnalytics200ResponseRangeTimezoneEnum timezone;
  @override
  final GetAdminAnalytics200ResponseRangePlatformEnum platform;
  @override
  final GetAdminAnalytics200ResponseRangeBucketEnum bucket;

  factory _$GetAdminAnalytics200ResponseRange(
          [void Function(GetAdminAnalytics200ResponseRangeBuilder)? updates]) =>
      (GetAdminAnalytics200ResponseRangeBuilder()..update(updates))._build();

  _$GetAdminAnalytics200ResponseRange._(
      {required this.startDate,
      required this.endDate,
      required this.timezone,
      required this.platform,
      required this.bucket})
      : super._();
  @override
  GetAdminAnalytics200ResponseRange rebuild(
          void Function(GetAdminAnalytics200ResponseRangeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalytics200ResponseRangeBuilder toBuilder() =>
      GetAdminAnalytics200ResponseRangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalytics200ResponseRange &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        timezone == other.timezone &&
        platform == other.platform &&
        bucket == other.bucket;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, bucket.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalytics200ResponseRange')
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('timezone', timezone)
          ..add('platform', platform)
          ..add('bucket', bucket))
        .toString();
  }
}

class GetAdminAnalytics200ResponseRangeBuilder
    implements
        Builder<GetAdminAnalytics200ResponseRange,
            GetAdminAnalytics200ResponseRangeBuilder> {
  _$GetAdminAnalytics200ResponseRange? _$v;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  String? _endDate;
  String? get endDate => _$this._endDate;
  set endDate(String? endDate) => _$this._endDate = endDate;

  GetAdminAnalytics200ResponseRangeTimezoneEnum? _timezone;
  GetAdminAnalytics200ResponseRangeTimezoneEnum? get timezone =>
      _$this._timezone;
  set timezone(GetAdminAnalytics200ResponseRangeTimezoneEnum? timezone) =>
      _$this._timezone = timezone;

  GetAdminAnalytics200ResponseRangePlatformEnum? _platform;
  GetAdminAnalytics200ResponseRangePlatformEnum? get platform =>
      _$this._platform;
  set platform(GetAdminAnalytics200ResponseRangePlatformEnum? platform) =>
      _$this._platform = platform;

  GetAdminAnalytics200ResponseRangeBucketEnum? _bucket;
  GetAdminAnalytics200ResponseRangeBucketEnum? get bucket => _$this._bucket;
  set bucket(GetAdminAnalytics200ResponseRangeBucketEnum? bucket) =>
      _$this._bucket = bucket;

  GetAdminAnalytics200ResponseRangeBuilder() {
    GetAdminAnalytics200ResponseRange._defaults(this);
  }

  GetAdminAnalytics200ResponseRangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _timezone = $v.timezone;
      _platform = $v.platform;
      _bucket = $v.bucket;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalytics200ResponseRange other) {
    _$v = other as _$GetAdminAnalytics200ResponseRange;
  }

  @override
  void update(
      void Function(GetAdminAnalytics200ResponseRangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalytics200ResponseRange build() => _build();

  _$GetAdminAnalytics200ResponseRange _build() {
    final _$result = _$v ??
        _$GetAdminAnalytics200ResponseRange._(
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'GetAdminAnalytics200ResponseRange', 'startDate'),
          endDate: BuiltValueNullFieldError.checkNotNull(
              endDate, r'GetAdminAnalytics200ResponseRange', 'endDate'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'GetAdminAnalytics200ResponseRange', 'timezone'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'GetAdminAnalytics200ResponseRange', 'platform'),
          bucket: BuiltValueNullFieldError.checkNotNull(
              bucket, r'GetAdminAnalytics200ResponseRange', 'bucket'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
