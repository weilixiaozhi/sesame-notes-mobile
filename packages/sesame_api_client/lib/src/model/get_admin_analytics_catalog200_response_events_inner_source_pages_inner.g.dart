// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_catalog200_response_events_inner_source_pages_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_app =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
        ._('app');
const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_web =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
        ._('web');

GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumValueOf(
        String name) {
  switch (name) {
    case 'app':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_app;
    case 'web':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumValues =
    BuiltSet<
        GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>(const <GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>[
  _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_app,
  _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_web,
]);

Serializer<
        GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumSerializer =
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumSerializer();

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'app': 'app',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'app': 'app',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
  ];
  @override
  final String wireName =
      'GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner
    extends GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner {
  @override
  final String pageId;
  @override
  final BuiltSet<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
      platforms;

  factory _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner(
          [void Function(
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner._(
      {required this.pageId, required this.platforms})
      : super._();
  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner rebuild(
          void Function(
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
      toBuilder() =>
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner &&
        pageId == other.pageId &&
        platforms == other.platforms;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pageId.hashCode);
    _$hash = $jc(_$hash, platforms.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner')
          ..add('pageId', pageId)
          ..add('platforms', platforms))
        .toString();
  }
}

class GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
    implements
        Builder<GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner,
            GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder> {
  _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner? _$v;

  String? _pageId;
  String? get pageId => _$this._pageId;
  set pageId(String? pageId) => _$this._pageId = pageId;

  SetBuilder<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>?
      _platforms;
  SetBuilder<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
      get platforms => _$this._platforms ??= SetBuilder<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>();
  set platforms(
          SetBuilder<
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>?
              platforms) =>
      _$this._platforms = platforms;

  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder() {
    GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner._defaults(
        this);
  }

  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _pageId = $v.pageId;
      _platforms = $v.platforms.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner other) {
    _$v = other
        as _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner;
  }

  @override
  void update(
      void Function(
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner build() =>
      _build();

  _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner _build() {
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner._(
            pageId: BuiltValueNullFieldError.checkNotNull(
                pageId,
                r'GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner',
                'pageId'),
            platforms: platforms.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'platforms';
        platforms.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner',
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
