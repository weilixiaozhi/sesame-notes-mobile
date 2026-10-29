// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_banner_statistics200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
    _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessPlanLibrary =
    const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum._(
        'fitnessPlanLibrary');
const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
    _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary =
    const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum._(
        'fitnessTemplateLibrary');

GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
    _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>
    _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumValues = BuiltSet<
        GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>(const <GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>[
  _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessPlanLibrary,
  _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary,
]);

const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
    _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_builtin =
    const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum._('builtin');
const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
    _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_remote =
    const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum._('remote');

GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
    _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumValueOf(
        String name) {
  switch (name) {
    case 'builtin':
      return _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_builtin;
    case 'remote':
      return _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_remote;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>
    _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumValues = BuiltSet<
        GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>(const <GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>[
  _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_builtin,
  _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_remote,
]);

Serializer<GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>
    _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumSerializer =
    _$GetAdminBannerStatistics200ResponseItemsInnerSlotEnumSerializer();
Serializer<GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>
    _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumSerializer =
    _$GetAdminBannerStatistics200ResponseItemsInnerSource_EnumSerializer();

class _$GetAdminBannerStatistics200ResponseItemsInnerSlotEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminBannerStatistics200ResponseItemsInnerSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
  ];
  @override
  final String wireName =
      'GetAdminBannerStatistics200ResponseItemsInnerSlotEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminBannerStatistics200ResponseItemsInnerSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminBannerStatistics200ResponseItemsInnerSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminBannerStatistics200ResponseItemsInnerSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminBannerStatistics200ResponseItemsInnerSource_EnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminBannerStatistics200ResponseItemsInnerSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'builtin': 'builtin',
    'remote': 'remote',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'builtin': 'builtin',
    'remote': 'remote',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
  ];
  @override
  final String wireName =
      'GetAdminBannerStatistics200ResponseItemsInnerSource_Enum';

  @override
  Object serialize(Serializers serializers,
          GetAdminBannerStatistics200ResponseItemsInnerSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminBannerStatistics200ResponseItemsInnerSource_Enum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminBannerStatistics200ResponseItemsInnerSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminBannerStatistics200ResponseItemsInner
    extends GetAdminBannerStatistics200ResponseItemsInner {
  @override
  final String bannerId;
  @override
  final GetAdminBannerStatistics200ResponseItemsInnerSlotEnum slot;
  @override
  final GetAdminBannerStatistics200ResponseItemsInnerSource_Enum source_;
  @override
  final int version;
  @override
  final int impressions;
  @override
  final int clicks;
  @override
  final num? ctr;

  factory _$GetAdminBannerStatistics200ResponseItemsInner(
          [void Function(GetAdminBannerStatistics200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminBannerStatistics200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminBannerStatistics200ResponseItemsInner._(
      {required this.bannerId,
      required this.slot,
      required this.source_,
      required this.version,
      required this.impressions,
      required this.clicks,
      this.ctr})
      : super._();
  @override
  GetAdminBannerStatistics200ResponseItemsInner rebuild(
          void Function(GetAdminBannerStatistics200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminBannerStatistics200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminBannerStatistics200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminBannerStatistics200ResponseItemsInner &&
        bannerId == other.bannerId &&
        slot == other.slot &&
        source_ == other.source_ &&
        version == other.version &&
        impressions == other.impressions &&
        clicks == other.clicks &&
        ctr == other.ctr;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bannerId.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, impressions.hashCode);
    _$hash = $jc(_$hash, clicks.hashCode);
    _$hash = $jc(_$hash, ctr.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminBannerStatistics200ResponseItemsInner')
          ..add('bannerId', bannerId)
          ..add('slot', slot)
          ..add('source_', source_)
          ..add('version', version)
          ..add('impressions', impressions)
          ..add('clicks', clicks)
          ..add('ctr', ctr))
        .toString();
  }
}

class GetAdminBannerStatistics200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminBannerStatistics200ResponseItemsInner,
            GetAdminBannerStatistics200ResponseItemsInnerBuilder> {
  _$GetAdminBannerStatistics200ResponseItemsInner? _$v;

  String? _bannerId;
  String? get bannerId => _$this._bannerId;
  set bannerId(String? bannerId) => _$this._bannerId = bannerId;

  GetAdminBannerStatistics200ResponseItemsInnerSlotEnum? _slot;
  GetAdminBannerStatistics200ResponseItemsInnerSlotEnum? get slot =>
      _$this._slot;
  set slot(GetAdminBannerStatistics200ResponseItemsInnerSlotEnum? slot) =>
      _$this._slot = slot;

  GetAdminBannerStatistics200ResponseItemsInnerSource_Enum? _source_;
  GetAdminBannerStatistics200ResponseItemsInnerSource_Enum? get source_ =>
      _$this._source_;
  set source_(
          GetAdminBannerStatistics200ResponseItemsInnerSource_Enum? source_) =>
      _$this._source_ = source_;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  int? _impressions;
  int? get impressions => _$this._impressions;
  set impressions(int? impressions) => _$this._impressions = impressions;

  int? _clicks;
  int? get clicks => _$this._clicks;
  set clicks(int? clicks) => _$this._clicks = clicks;

  num? _ctr;
  num? get ctr => _$this._ctr;
  set ctr(num? ctr) => _$this._ctr = ctr;

  GetAdminBannerStatistics200ResponseItemsInnerBuilder() {
    GetAdminBannerStatistics200ResponseItemsInner._defaults(this);
  }

  GetAdminBannerStatistics200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bannerId = $v.bannerId;
      _slot = $v.slot;
      _source_ = $v.source_;
      _version = $v.version;
      _impressions = $v.impressions;
      _clicks = $v.clicks;
      _ctr = $v.ctr;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminBannerStatistics200ResponseItemsInner other) {
    _$v = other as _$GetAdminBannerStatistics200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminBannerStatistics200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminBannerStatistics200ResponseItemsInner build() => _build();

  _$GetAdminBannerStatistics200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminBannerStatistics200ResponseItemsInner._(
          bannerId: BuiltValueNullFieldError.checkNotNull(bannerId,
              r'GetAdminBannerStatistics200ResponseItemsInner', 'bannerId'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'GetAdminBannerStatistics200ResponseItemsInner', 'slot'),
          source_: BuiltValueNullFieldError.checkNotNull(source_,
              r'GetAdminBannerStatistics200ResponseItemsInner', 'source_'),
          version: BuiltValueNullFieldError.checkNotNull(version,
              r'GetAdminBannerStatistics200ResponseItemsInner', 'version'),
          impressions: BuiltValueNullFieldError.checkNotNull(impressions,
              r'GetAdminBannerStatistics200ResponseItemsInner', 'impressions'),
          clicks: BuiltValueNullFieldError.checkNotNull(clicks,
              r'GetAdminBannerStatistics200ResponseItemsInner', 'clicks'),
          ctr: ctr,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
