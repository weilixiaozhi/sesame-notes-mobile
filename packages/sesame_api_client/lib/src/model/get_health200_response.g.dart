// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_health200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetHealth200Response extends GetHealth200Response {
  @override
  final String status;
  @override
  final String requestId;

  factory _$GetHealth200Response(
          [void Function(GetHealth200ResponseBuilder)? updates]) =>
      (GetHealth200ResponseBuilder()..update(updates))._build();

  _$GetHealth200Response._({required this.status, required this.requestId})
      : super._();
  @override
  GetHealth200Response rebuild(
          void Function(GetHealth200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetHealth200ResponseBuilder toBuilder() =>
      GetHealth200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetHealth200Response &&
        status == other.status &&
        requestId == other.requestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetHealth200Response')
          ..add('status', status)
          ..add('requestId', requestId))
        .toString();
  }
}

class GetHealth200ResponseBuilder
    implements Builder<GetHealth200Response, GetHealth200ResponseBuilder> {
  _$GetHealth200Response? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  GetHealth200ResponseBuilder() {
    GetHealth200Response._defaults(this);
  }

  GetHealth200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _requestId = $v.requestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetHealth200Response other) {
    _$v = other as _$GetHealth200Response;
  }

  @override
  void update(void Function(GetHealth200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetHealth200Response build() => _build();

  _$GetHealth200Response _build() {
    final _$result = _$v ??
        _$GetHealth200Response._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'GetHealth200Response', 'status'),
          requestId: BuiltValueNullFieldError.checkNotNull(
              requestId, r'GetHealth200Response', 'requestId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
