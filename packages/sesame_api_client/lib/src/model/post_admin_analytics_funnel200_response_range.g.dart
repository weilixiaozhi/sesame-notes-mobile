// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_analytics_funnel200_response_range.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum
    _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnum_asiaSlashShanghai =
    const PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum._(
        'asiaSlashShanghai');

PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum
    _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumValueOf(String name) {
  switch (name) {
    case 'asiaSlashShanghai':
      return _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnum_asiaSlashShanghai;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>
    _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumValues = BuiltSet<
        PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>(const <PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>[
  _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnum_asiaSlashShanghai,
]);

const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_all =
    const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum._('all');
const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_app =
    const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum._('app');
const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_web =
    const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum._('web');

PostAdminAnalyticsFunnel200ResponseRangePlatformEnum
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumValueOf(String name) {
  switch (name) {
    case 'all':
      return _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_all;
    case 'app':
      return _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_app;
    case 'web':
      return _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumValues = BuiltSet<
        PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>(const <PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>[
  _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_all,
  _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_app,
  _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_web,
]);

Serializer<PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>
    _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumSerializer =
    _$PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnumSerializer();
Serializer<PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>
    _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumSerializer =
    _$PostAdminAnalyticsFunnel200ResponseRangePlatformEnumSerializer();

class _$PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnumSerializer
    implements
        PrimitiveSerializer<
            PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'asiaSlashShanghai': 'Asia/Shanghai',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Asia/Shanghai': 'asiaSlashShanghai',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum
  ];
  @override
  final String wireName =
      'PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAnalyticsFunnel200ResponseRangePlatformEnumSerializer
    implements
        PrimitiveSerializer<
            PostAdminAnalyticsFunnel200ResponseRangePlatformEnum> {
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
    PostAdminAnalyticsFunnel200ResponseRangePlatformEnum
  ];
  @override
  final String wireName =
      'PostAdminAnalyticsFunnel200ResponseRangePlatformEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAnalyticsFunnel200ResponseRangePlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAnalyticsFunnel200ResponseRangePlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAnalyticsFunnel200ResponseRangePlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAnalyticsFunnel200ResponseRange
    extends PostAdminAnalyticsFunnel200ResponseRange {
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum timezone;
  @override
  final PostAdminAnalyticsFunnel200ResponseRangePlatformEnum platform;

  factory _$PostAdminAnalyticsFunnel200ResponseRange(
          [void Function(PostAdminAnalyticsFunnel200ResponseRangeBuilder)?
              updates]) =>
      (PostAdminAnalyticsFunnel200ResponseRangeBuilder()..update(updates))
          ._build();

  _$PostAdminAnalyticsFunnel200ResponseRange._(
      {required this.startDate,
      required this.endDate,
      required this.timezone,
      required this.platform})
      : super._();
  @override
  PostAdminAnalyticsFunnel200ResponseRange rebuild(
          void Function(PostAdminAnalyticsFunnel200ResponseRangeBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAnalyticsFunnel200ResponseRangeBuilder toBuilder() =>
      PostAdminAnalyticsFunnel200ResponseRangeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAnalyticsFunnel200ResponseRange &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        timezone == other.timezone &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminAnalyticsFunnel200ResponseRange')
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('timezone', timezone)
          ..add('platform', platform))
        .toString();
  }
}

class PostAdminAnalyticsFunnel200ResponseRangeBuilder
    implements
        Builder<PostAdminAnalyticsFunnel200ResponseRange,
            PostAdminAnalyticsFunnel200ResponseRangeBuilder> {
  _$PostAdminAnalyticsFunnel200ResponseRange? _$v;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  String? _endDate;
  String? get endDate => _$this._endDate;
  set endDate(String? endDate) => _$this._endDate = endDate;

  PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum? _timezone;
  PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum? get timezone =>
      _$this._timezone;
  set timezone(
          PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum? timezone) =>
      _$this._timezone = timezone;

  PostAdminAnalyticsFunnel200ResponseRangePlatformEnum? _platform;
  PostAdminAnalyticsFunnel200ResponseRangePlatformEnum? get platform =>
      _$this._platform;
  set platform(
          PostAdminAnalyticsFunnel200ResponseRangePlatformEnum? platform) =>
      _$this._platform = platform;

  PostAdminAnalyticsFunnel200ResponseRangeBuilder() {
    PostAdminAnalyticsFunnel200ResponseRange._defaults(this);
  }

  PostAdminAnalyticsFunnel200ResponseRangeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _timezone = $v.timezone;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAnalyticsFunnel200ResponseRange other) {
    _$v = other as _$PostAdminAnalyticsFunnel200ResponseRange;
  }

  @override
  void update(
      void Function(PostAdminAnalyticsFunnel200ResponseRangeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAnalyticsFunnel200ResponseRange build() => _build();

  _$PostAdminAnalyticsFunnel200ResponseRange _build() {
    final _$result = _$v ??
        _$PostAdminAnalyticsFunnel200ResponseRange._(
          startDate: BuiltValueNullFieldError.checkNotNull(startDate,
              r'PostAdminAnalyticsFunnel200ResponseRange', 'startDate'),
          endDate: BuiltValueNullFieldError.checkNotNull(
              endDate, r'PostAdminAnalyticsFunnel200ResponseRange', 'endDate'),
          timezone: BuiltValueNullFieldError.checkNotNull(timezone,
              r'PostAdminAnalyticsFunnel200ResponseRange', 'timezone'),
          platform: BuiltValueNullFieldError.checkNotNull(platform,
              r'PostAdminAnalyticsFunnel200ResponseRange', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
