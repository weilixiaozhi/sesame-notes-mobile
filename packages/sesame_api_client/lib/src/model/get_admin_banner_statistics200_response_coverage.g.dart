// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_banner_statistics200_response_coverage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminBannerStatistics200ResponseCoverageAudienceEnum
    _$getAdminBannerStatistics200ResponseCoverageAudienceEnum_authenticatedUsers =
    const GetAdminBannerStatistics200ResponseCoverageAudienceEnum._(
        'authenticatedUsers');

GetAdminBannerStatistics200ResponseCoverageAudienceEnum
    _$getAdminBannerStatistics200ResponseCoverageAudienceEnumValueOf(
        String name) {
  switch (name) {
    case 'authenticatedUsers':
      return _$getAdminBannerStatistics200ResponseCoverageAudienceEnum_authenticatedUsers;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminBannerStatistics200ResponseCoverageAudienceEnum>
    _$getAdminBannerStatistics200ResponseCoverageAudienceEnumValues = BuiltSet<
        GetAdminBannerStatistics200ResponseCoverageAudienceEnum>(const <GetAdminBannerStatistics200ResponseCoverageAudienceEnum>[
  _$getAdminBannerStatistics200ResponseCoverageAudienceEnum_authenticatedUsers,
]);

Serializer<GetAdminBannerStatistics200ResponseCoverageAudienceEnum>
    _$getAdminBannerStatistics200ResponseCoverageAudienceEnumSerializer =
    _$GetAdminBannerStatistics200ResponseCoverageAudienceEnumSerializer();

class _$GetAdminBannerStatistics200ResponseCoverageAudienceEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminBannerStatistics200ResponseCoverageAudienceEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'authenticatedUsers': 'authenticated_users',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'authenticated_users': 'authenticatedUsers',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminBannerStatistics200ResponseCoverageAudienceEnum
  ];
  @override
  final String wireName =
      'GetAdminBannerStatistics200ResponseCoverageAudienceEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminBannerStatistics200ResponseCoverageAudienceEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminBannerStatistics200ResponseCoverageAudienceEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminBannerStatistics200ResponseCoverageAudienceEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminBannerStatistics200ResponseCoverage
    extends GetAdminBannerStatistics200ResponseCoverage {
  @override
  final DateTime collectionStartedAt;
  @override
  final bool complete;
  @override
  final GetAdminBannerStatistics200ResponseCoverageAudienceEnum audience;

  factory _$GetAdminBannerStatistics200ResponseCoverage(
          [void Function(GetAdminBannerStatistics200ResponseCoverageBuilder)?
              updates]) =>
      (GetAdminBannerStatistics200ResponseCoverageBuilder()..update(updates))
          ._build();

  _$GetAdminBannerStatistics200ResponseCoverage._(
      {required this.collectionStartedAt,
      required this.complete,
      required this.audience})
      : super._();
  @override
  GetAdminBannerStatistics200ResponseCoverage rebuild(
          void Function(GetAdminBannerStatistics200ResponseCoverageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminBannerStatistics200ResponseCoverageBuilder toBuilder() =>
      GetAdminBannerStatistics200ResponseCoverageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminBannerStatistics200ResponseCoverage &&
        collectionStartedAt == other.collectionStartedAt &&
        complete == other.complete &&
        audience == other.audience;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, collectionStartedAt.hashCode);
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jc(_$hash, audience.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminBannerStatistics200ResponseCoverage')
          ..add('collectionStartedAt', collectionStartedAt)
          ..add('complete', complete)
          ..add('audience', audience))
        .toString();
  }
}

class GetAdminBannerStatistics200ResponseCoverageBuilder
    implements
        Builder<GetAdminBannerStatistics200ResponseCoverage,
            GetAdminBannerStatistics200ResponseCoverageBuilder> {
  _$GetAdminBannerStatistics200ResponseCoverage? _$v;

  DateTime? _collectionStartedAt;
  DateTime? get collectionStartedAt => _$this._collectionStartedAt;
  set collectionStartedAt(DateTime? collectionStartedAt) =>
      _$this._collectionStartedAt = collectionStartedAt;

  bool? _complete;
  bool? get complete => _$this._complete;
  set complete(bool? complete) => _$this._complete = complete;

  GetAdminBannerStatistics200ResponseCoverageAudienceEnum? _audience;
  GetAdminBannerStatistics200ResponseCoverageAudienceEnum? get audience =>
      _$this._audience;
  set audience(
          GetAdminBannerStatistics200ResponseCoverageAudienceEnum? audience) =>
      _$this._audience = audience;

  GetAdminBannerStatistics200ResponseCoverageBuilder() {
    GetAdminBannerStatistics200ResponseCoverage._defaults(this);
  }

  GetAdminBannerStatistics200ResponseCoverageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _collectionStartedAt = $v.collectionStartedAt;
      _complete = $v.complete;
      _audience = $v.audience;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminBannerStatistics200ResponseCoverage other) {
    _$v = other as _$GetAdminBannerStatistics200ResponseCoverage;
  }

  @override
  void update(
      void Function(GetAdminBannerStatistics200ResponseCoverageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminBannerStatistics200ResponseCoverage build() => _build();

  _$GetAdminBannerStatistics200ResponseCoverage _build() {
    final _$result = _$v ??
        _$GetAdminBannerStatistics200ResponseCoverage._(
          collectionStartedAt: BuiltValueNullFieldError.checkNotNull(
              collectionStartedAt,
              r'GetAdminBannerStatistics200ResponseCoverage',
              'collectionStartedAt'),
          complete: BuiltValueNullFieldError.checkNotNull(complete,
              r'GetAdminBannerStatistics200ResponseCoverage', 'complete'),
          audience: BuiltValueNullFieldError.checkNotNull(audience,
              r'GetAdminBannerStatistics200ResponseCoverage', 'audience'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
