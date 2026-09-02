// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_status200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminStatus200Response extends GetAdminStatus200Response {
  @override
  final GetAdminStatus200ResponseUsers users;
  @override
  final GetAdminStatus200ResponseLedgers ledgers;
  @override
  final GetAdminStatus200ResponseLedgers devices;
  @override
  final GetAdminStatus200ResponseLedgers syncChanges;
  @override
  final GetAdminStatus200ResponseLedgers auditLogs;

  factory _$GetAdminStatus200Response(
          [void Function(GetAdminStatus200ResponseBuilder)? updates]) =>
      (GetAdminStatus200ResponseBuilder()..update(updates))._build();

  _$GetAdminStatus200Response._(
      {required this.users,
      required this.ledgers,
      required this.devices,
      required this.syncChanges,
      required this.auditLogs})
      : super._();
  @override
  GetAdminStatus200Response rebuild(
          void Function(GetAdminStatus200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminStatus200ResponseBuilder toBuilder() =>
      GetAdminStatus200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminStatus200Response &&
        users == other.users &&
        ledgers == other.ledgers &&
        devices == other.devices &&
        syncChanges == other.syncChanges &&
        auditLogs == other.auditLogs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jc(_$hash, ledgers.hashCode);
    _$hash = $jc(_$hash, devices.hashCode);
    _$hash = $jc(_$hash, syncChanges.hashCode);
    _$hash = $jc(_$hash, auditLogs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminStatus200Response')
          ..add('users', users)
          ..add('ledgers', ledgers)
          ..add('devices', devices)
          ..add('syncChanges', syncChanges)
          ..add('auditLogs', auditLogs))
        .toString();
  }
}

class GetAdminStatus200ResponseBuilder
    implements
        Builder<GetAdminStatus200Response, GetAdminStatus200ResponseBuilder> {
  _$GetAdminStatus200Response? _$v;

  GetAdminStatus200ResponseUsersBuilder? _users;
  GetAdminStatus200ResponseUsersBuilder get users =>
      _$this._users ??= GetAdminStatus200ResponseUsersBuilder();
  set users(GetAdminStatus200ResponseUsersBuilder? users) =>
      _$this._users = users;

  GetAdminStatus200ResponseLedgersBuilder? _ledgers;
  GetAdminStatus200ResponseLedgersBuilder get ledgers =>
      _$this._ledgers ??= GetAdminStatus200ResponseLedgersBuilder();
  set ledgers(GetAdminStatus200ResponseLedgersBuilder? ledgers) =>
      _$this._ledgers = ledgers;

  GetAdminStatus200ResponseLedgersBuilder? _devices;
  GetAdminStatus200ResponseLedgersBuilder get devices =>
      _$this._devices ??= GetAdminStatus200ResponseLedgersBuilder();
  set devices(GetAdminStatus200ResponseLedgersBuilder? devices) =>
      _$this._devices = devices;

  GetAdminStatus200ResponseLedgersBuilder? _syncChanges;
  GetAdminStatus200ResponseLedgersBuilder get syncChanges =>
      _$this._syncChanges ??= GetAdminStatus200ResponseLedgersBuilder();
  set syncChanges(GetAdminStatus200ResponseLedgersBuilder? syncChanges) =>
      _$this._syncChanges = syncChanges;

  GetAdminStatus200ResponseLedgersBuilder? _auditLogs;
  GetAdminStatus200ResponseLedgersBuilder get auditLogs =>
      _$this._auditLogs ??= GetAdminStatus200ResponseLedgersBuilder();
  set auditLogs(GetAdminStatus200ResponseLedgersBuilder? auditLogs) =>
      _$this._auditLogs = auditLogs;

  GetAdminStatus200ResponseBuilder() {
    GetAdminStatus200Response._defaults(this);
  }

  GetAdminStatus200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _users = $v.users.toBuilder();
      _ledgers = $v.ledgers.toBuilder();
      _devices = $v.devices.toBuilder();
      _syncChanges = $v.syncChanges.toBuilder();
      _auditLogs = $v.auditLogs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminStatus200Response other) {
    _$v = other as _$GetAdminStatus200Response;
  }

  @override
  void update(void Function(GetAdminStatus200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminStatus200Response build() => _build();

  _$GetAdminStatus200Response _build() {
    _$GetAdminStatus200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminStatus200Response._(
            users: users.build(),
            ledgers: ledgers.build(),
            devices: devices.build(),
            syncChanges: syncChanges.build(),
            auditLogs: auditLogs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'users';
        users.build();
        _$failedField = 'ledgers';
        ledgers.build();
        _$failedField = 'devices';
        devices.build();
        _$failedField = 'syncChanges';
        syncChanges.build();
        _$failedField = 'auditLogs';
        auditLogs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminStatus200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
