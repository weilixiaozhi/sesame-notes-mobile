// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthRegisterRequest extends PostAuthRegisterRequest {
  @override
  final String countryCode;
  @override
  final String phone;
  @override
  final String password;
  @override
  final PostAuthRegisterRequestDevice device;

  factory _$PostAuthRegisterRequest(
          [void Function(PostAuthRegisterRequestBuilder)? updates]) =>
      (PostAuthRegisterRequestBuilder()..update(updates))._build();

  _$PostAuthRegisterRequest._(
      {required this.countryCode,
      required this.phone,
      required this.password,
      required this.device})
      : super._();
  @override
  PostAuthRegisterRequest rebuild(
          void Function(PostAuthRegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthRegisterRequestBuilder toBuilder() =>
      PostAuthRegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthRegisterRequest &&
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
    return (newBuiltValueToStringHelper(r'PostAuthRegisterRequest')
          ..add('countryCode', countryCode)
          ..add('phone', phone)
          ..add('password', password)
          ..add('device', device))
        .toString();
  }
}

class PostAuthRegisterRequestBuilder
    implements
        Builder<PostAuthRegisterRequest, PostAuthRegisterRequestBuilder> {
  _$PostAuthRegisterRequest? _$v;

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

  PostAuthRegisterRequestBuilder() {
    PostAuthRegisterRequest._defaults(this);
  }

  PostAuthRegisterRequestBuilder get _$this {
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
  void replace(PostAuthRegisterRequest other) {
    _$v = other as _$PostAuthRegisterRequest;
  }

  @override
  void update(void Function(PostAuthRegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthRegisterRequest build() => _build();

  _$PostAuthRegisterRequest _build() {
    _$PostAuthRegisterRequest _$result;
    try {
      _$result = _$v ??
          _$PostAuthRegisterRequest._(
            countryCode: BuiltValueNullFieldError.checkNotNull(
                countryCode, r'PostAuthRegisterRequest', 'countryCode'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'PostAuthRegisterRequest', 'phone'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'PostAuthRegisterRequest', 'password'),
            device: device.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'device';
        device.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAuthRegisterRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
