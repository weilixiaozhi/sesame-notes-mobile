// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_admin_users_by_user_id_phone_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutAdminUsersByUserIdPhoneRequest
    extends PutAdminUsersByUserIdPhoneRequest {
  @override
  final String countryCode;
  @override
  final String phone;
  @override
  final String currentPhone;
  @override
  final String reason;

  factory _$PutAdminUsersByUserIdPhoneRequest(
          [void Function(PutAdminUsersByUserIdPhoneRequestBuilder)? updates]) =>
      (PutAdminUsersByUserIdPhoneRequestBuilder()..update(updates))._build();

  _$PutAdminUsersByUserIdPhoneRequest._(
      {required this.countryCode,
      required this.phone,
      required this.currentPhone,
      required this.reason})
      : super._();
  @override
  PutAdminUsersByUserIdPhoneRequest rebuild(
          void Function(PutAdminUsersByUserIdPhoneRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutAdminUsersByUserIdPhoneRequestBuilder toBuilder() =>
      PutAdminUsersByUserIdPhoneRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutAdminUsersByUserIdPhoneRequest &&
        countryCode == other.countryCode &&
        phone == other.phone &&
        currentPhone == other.currentPhone &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, countryCode.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, currentPhone.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutAdminUsersByUserIdPhoneRequest')
          ..add('countryCode', countryCode)
          ..add('phone', phone)
          ..add('currentPhone', currentPhone)
          ..add('reason', reason))
        .toString();
  }
}

class PutAdminUsersByUserIdPhoneRequestBuilder
    implements
        Builder<PutAdminUsersByUserIdPhoneRequest,
            PutAdminUsersByUserIdPhoneRequestBuilder> {
  _$PutAdminUsersByUserIdPhoneRequest? _$v;

  String? _countryCode;
  String? get countryCode => _$this._countryCode;
  set countryCode(String? countryCode) => _$this._countryCode = countryCode;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _currentPhone;
  String? get currentPhone => _$this._currentPhone;
  set currentPhone(String? currentPhone) => _$this._currentPhone = currentPhone;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PutAdminUsersByUserIdPhoneRequestBuilder() {
    PutAdminUsersByUserIdPhoneRequest._defaults(this);
  }

  PutAdminUsersByUserIdPhoneRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _countryCode = $v.countryCode;
      _phone = $v.phone;
      _currentPhone = $v.currentPhone;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutAdminUsersByUserIdPhoneRequest other) {
    _$v = other as _$PutAdminUsersByUserIdPhoneRequest;
  }

  @override
  void update(
      void Function(PutAdminUsersByUserIdPhoneRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutAdminUsersByUserIdPhoneRequest build() => _build();

  _$PutAdminUsersByUserIdPhoneRequest _build() {
    final _$result = _$v ??
        _$PutAdminUsersByUserIdPhoneRequest._(
          countryCode: BuiltValueNullFieldError.checkNotNull(
              countryCode, r'PutAdminUsersByUserIdPhoneRequest', 'countryCode'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'PutAdminUsersByUserIdPhoneRequest', 'phone'),
          currentPhone: BuiltValueNullFieldError.checkNotNull(currentPhone,
              r'PutAdminUsersByUserIdPhoneRequest', 'currentPhone'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PutAdminUsersByUserIdPhoneRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
