// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_status200_response_users.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminStatus200ResponseUsers extends GetAdminStatus200ResponseUsers {
  @override
  final int total;
  @override
  final int enabled;
  @override
  final int admins;

  factory _$GetAdminStatus200ResponseUsers(
          [void Function(GetAdminStatus200ResponseUsersBuilder)? updates]) =>
      (GetAdminStatus200ResponseUsersBuilder()..update(updates))._build();

  _$GetAdminStatus200ResponseUsers._(
      {required this.total, required this.enabled, required this.admins})
      : super._();
  @override
  GetAdminStatus200ResponseUsers rebuild(
          void Function(GetAdminStatus200ResponseUsersBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminStatus200ResponseUsersBuilder toBuilder() =>
      GetAdminStatus200ResponseUsersBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminStatus200ResponseUsers &&
        total == other.total &&
        enabled == other.enabled &&
        admins == other.admins;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, admins.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminStatus200ResponseUsers')
          ..add('total', total)
          ..add('enabled', enabled)
          ..add('admins', admins))
        .toString();
  }
}

class GetAdminStatus200ResponseUsersBuilder
    implements
        Builder<GetAdminStatus200ResponseUsers,
            GetAdminStatus200ResponseUsersBuilder> {
  _$GetAdminStatus200ResponseUsers? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _enabled;
  int? get enabled => _$this._enabled;
  set enabled(int? enabled) => _$this._enabled = enabled;

  int? _admins;
  int? get admins => _$this._admins;
  set admins(int? admins) => _$this._admins = admins;

  GetAdminStatus200ResponseUsersBuilder() {
    GetAdminStatus200ResponseUsers._defaults(this);
  }

  GetAdminStatus200ResponseUsersBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _enabled = $v.enabled;
      _admins = $v.admins;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminStatus200ResponseUsers other) {
    _$v = other as _$GetAdminStatus200ResponseUsers;
  }

  @override
  void update(void Function(GetAdminStatus200ResponseUsersBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminStatus200ResponseUsers build() => _build();

  _$GetAdminStatus200ResponseUsers _build() {
    final _$result = _$v ??
        _$GetAdminStatus200ResponseUsers._(
          total: BuiltValueNullFieldError.checkNotNull(
              total, r'GetAdminStatus200ResponseUsers', 'total'),
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'GetAdminStatus200ResponseUsers', 'enabled'),
          admins: BuiltValueNullFieldError.checkNotNull(
              admins, r'GetAdminStatus200ResponseUsers', 'admins'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
