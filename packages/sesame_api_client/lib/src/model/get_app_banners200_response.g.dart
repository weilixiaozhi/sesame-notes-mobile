// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAppBanners200Response extends GetAppBanners200Response {
  @override
  final AnyOf anyOf;

  factory _$GetAppBanners200Response(
          [void Function(GetAppBanners200ResponseBuilder)? updates]) =>
      (GetAppBanners200ResponseBuilder()..update(updates))._build();

  _$GetAppBanners200Response._({required this.anyOf}) : super._();
  @override
  GetAppBanners200Response rebuild(
          void Function(GetAppBanners200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseBuilder toBuilder() =>
      GetAppBanners200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200Response && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAppBanners200Response')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class GetAppBanners200ResponseBuilder
    implements
        Builder<GetAppBanners200Response, GetAppBanners200ResponseBuilder> {
  _$GetAppBanners200Response? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  GetAppBanners200ResponseBuilder() {
    GetAppBanners200Response._defaults(this);
  }

  GetAppBanners200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200Response other) {
    _$v = other as _$GetAppBanners200Response;
  }

  @override
  void update(void Function(GetAppBanners200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200Response build() => _build();

  _$GetAppBanners200Response _build() {
    final _$result = _$v ??
        _$GetAppBanners200Response._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'GetAppBanners200Response', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
