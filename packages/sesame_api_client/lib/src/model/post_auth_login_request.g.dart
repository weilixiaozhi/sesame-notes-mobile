// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthLoginRequest extends PostAuthLoginRequest {
  @override
  final String countryCode;
  @override
  final String phone;
  @override
  final String password;
  @override
  final PostAuthRegisterRequestDevice device;

  factory _$PostAuthLoginRequest(
          [void Function(PostAuthLoginRequestBuilder)? updates]) =>
      (PostAuthLoginRequestBuilder()..update(updates))._build();

  _$PostAuthLoginRequest._(
      {required this.countryCode,
      required this.phone,
      required this.password,
      required this.device})
      : super._();
  @override
  PostAuthLoginRequest rebuild(
          void Function(PostAuthLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthLoginRequestBuilder toBuilder() =>
      PostAuthLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthLoginRequest &&
        countryCode == other.countryCode &&
        phone == other.phone &&
        password == other.password &&
        device == other.device;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, countryCode.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthLoginRequest')
          ..add('countryCode', countryCode)
          ..add('phone', phone)
          ..add('password', password)
          ..add('device', device))
        .toString();
  }
}

class PostAuthLoginRequestBuilder
    implements Builder<PostAuthLoginRequest, PostAuthLoginRequestBuilder> {
  _$PostAuthLoginRequest? _$v;

  String? _countryCode;
  String? get countryCode => _$this._countryCode;
  set countryCode(String? countryCode) => _$this._countryCode = countryCode;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  PostAuthRegisterRequestDeviceBuilder? _device;
  PostAuthRegisterRequestDeviceBuilder get device =>
      _$this._device ??= PostAuthRegisterRequestDeviceBuilder();
  set device(PostAuthRegisterRequestDeviceBuilder? device) =>
      _$this._device = device;

  PostAuthLoginRequestBuilder() {
    PostAuthLoginRequest._defaults(this);
  }

  PostAuthLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _countryCode = $v.countryCode;
      _phone = $v.phone;
      _password = $v.password;
      _device = $v.device.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthLoginRequest other) {
    _$v = other as _$PostAuthLoginRequest;
  }

  @override
  void update(void Function(PostAuthLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthLoginRequest build() => _build();

  _$PostAuthLoginRequest _build() {
    _$PostAuthLoginRequest _$result;
    try {
      _$result = _$v ??
          _$PostAuthLoginRequest._(
            countryCode: BuiltValueNullFieldError.checkNotNull(
                countryCode, r'PostAuthLoginRequest', 'countryCode'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'PostAuthLoginRequest', 'phone'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'PostAuthLoginRequest', 'password'),
            device: device.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'device';
        device.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAuthLoginRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
