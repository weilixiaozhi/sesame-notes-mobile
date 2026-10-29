// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_banner_statistics200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminBannerStatistics200ResponseScopeEnum
    _$getAdminBannerStatistics200ResponseScopeEnum_current =
    const GetAdminBannerStatistics200ResponseScopeEnum._('current');

GetAdminBannerStatistics200ResponseScopeEnum
    _$getAdminBannerStatistics200ResponseScopeEnumValueOf(String name) {
  switch (name) {
    case 'current':
      return _$getAdminBannerStatistics200ResponseScopeEnum_current;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminBannerStatistics200ResponseScopeEnum>
    _$getAdminBannerStatistics200ResponseScopeEnumValues = BuiltSet<
        GetAdminBannerStatistics200ResponseScopeEnum>(const <GetAdminBannerStatistics200ResponseScopeEnum>[
  _$getAdminBannerStatistics200ResponseScopeEnum_current,
]);

Serializer<GetAdminBannerStatistics200ResponseScopeEnum>
    _$getAdminBannerStatistics200ResponseScopeEnumSerializer =
    _$GetAdminBannerStatistics200ResponseScopeEnumSerializer();

class _$GetAdminBannerStatistics200ResponseScopeEnumSerializer
    implements
        PrimitiveSerializer<GetAdminBannerStatistics200ResponseScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'current': 'current',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'current': 'current',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminBannerStatistics200ResponseScopeEnum
  ];
  @override
  final String wireName = 'GetAdminBannerStatistics200ResponseScopeEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminBannerStatistics200ResponseScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminBannerStatistics200ResponseScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminBannerStatistics200ResponseScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminBannerStatistics200Response
    extends GetAdminBannerStatistics200Response {
  @override
  final GetAdminBannerStatistics200ResponseRange range;
  @override
  final GetAdminBannerStatistics200ResponseScopeEnum scope;
  @override
  final BuiltList<GetAdminBannerStatistics200ResponseItemsInner> items;
  @override
  final GetAdminBannerStatistics200ResponseCoverage coverage;

  factory _$GetAdminBannerStatistics200Response(
          [void Function(GetAdminBannerStatistics200ResponseBuilder)?
              updates]) =>
      (GetAdminBannerStatistics200ResponseBuilder()..update(updates))._build();

  _$GetAdminBannerStatistics200Response._(
      {required this.range,
      required this.scope,
      required this.items,
      required this.coverage})
      : super._();
  @override
  GetAdminBannerStatistics200Response rebuild(
          void Function(GetAdminBannerStatistics200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminBannerStatistics200ResponseBuilder toBuilder() =>
      GetAdminBannerStatistics200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminBannerStatistics200Response &&
        range == other.range &&
        scope == other.scope &&
        items == other.items &&
        coverage == other.coverage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminBannerStatistics200Response')
          ..add('range', range)
          ..add('scope', scope)
          ..add('items', items)
          ..add('coverage', coverage))
        .toString();
  }
}

class GetAdminBannerStatistics200ResponseBuilder
    implements
        Builder<GetAdminBannerStatistics200Response,
            GetAdminBannerStatistics200ResponseBuilder> {
  _$GetAdminBannerStatistics200Response? _$v;

  GetAdminBannerStatistics200ResponseRangeBuilder? _range;
  GetAdminBannerStatistics200ResponseRangeBuilder get range =>
      _$this._range ??= GetAdminBannerStatistics200ResponseRangeBuilder();
  set range(GetAdminBannerStatistics200ResponseRangeBuilder? range) =>
      _$this._range = range;

  GetAdminBannerStatistics200ResponseScopeEnum? _scope;
  GetAdminBannerStatistics200ResponseScopeEnum? get scope => _$this._scope;
  set scope(GetAdminBannerStatistics200ResponseScopeEnum? scope) =>
      _$this._scope = scope;

  ListBuilder<GetAdminBannerStatistics200ResponseItemsInner>? _items;
  ListBuilder<GetAdminBannerStatistics200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetAdminBannerStatistics200ResponseItemsInner>();
  set items(
          ListBuilder<GetAdminBannerStatistics200ResponseItemsInner>? items) =>
      _$this._items = items;

  GetAdminBannerStatistics200ResponseCoverageBuilder? _coverage;
  GetAdminBannerStatistics200ResponseCoverageBuilder get coverage =>
      _$this._coverage ??= GetAdminBannerStatistics200ResponseCoverageBuilder();
  set coverage(GetAdminBannerStatistics200ResponseCoverageBuilder? coverage) =>
      _$this._coverage = coverage;

  GetAdminBannerStatistics200ResponseBuilder() {
    GetAdminBannerStatistics200Response._defaults(this);
  }

  GetAdminBannerStatistics200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _scope = $v.scope;
      _items = $v.items.toBuilder();
      _coverage = $v.coverage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminBannerStatistics200Response other) {
    _$v = other as _$GetAdminBannerStatistics200Response;
  }

  @override
  void update(
      void Function(GetAdminBannerStatistics200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminBannerStatistics200Response build() => _build();

  _$GetAdminBannerStatistics200Response _build() {
    _$GetAdminBannerStatistics200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminBannerStatistics200Response._(
            range: range.build(),
            scope: BuiltValueNullFieldError.checkNotNull(
                scope, r'GetAdminBannerStatistics200Response', 'scope'),
            items: items.build(),
            coverage: coverage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'range';
        range.build();

        _$failedField = 'items';
        items.build();
        _$failedField = 'coverage';
        coverage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GetAdminBannerStatistics200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
