// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users_by_user_id_devices200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminUsersByUserIdDevices200ResponseItemsInner
    extends GetAdminUsersByUserIdDevices200ResponseItemsInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final String platform;
  @override
  final String? appVersion;
  @override
  final String? osVersion;
  @override
  final String? deviceModel;
  @override
  final String? lastIp;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastSeenAt;
  @override
  final DateTime? revokedAt;

  factory _$GetAdminUsersByUserIdDevices200ResponseItemsInner(
          [void Function(
                  GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminUsersByUserIdDevices200ResponseItemsInner._(
      {required this.id,
      required this.name,
      required this.platform,
      this.appVersion,
      this.osVersion,
      this.deviceModel,
      this.lastIp,
      required this.createdAt,
      required this.lastSeenAt,
      this.revokedAt})
      : super._();
  @override
  GetAdminUsersByUserIdDevices200ResponseItemsInner rebuild(
          void Function(
                  GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsersByUserIdDevices200ResponseItemsInner &&
        id == other.id &&
        name == other.name &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        osVersion == other.osVersion &&
        deviceModel == other.deviceModel &&
        lastIp == other.lastIp &&
        createdAt == other.createdAt &&
        lastSeenAt == other.lastSeenAt &&
        revokedAt == other.revokedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, osVersion.hashCode);
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jc(_$hash, lastIp.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminUsersByUserIdDevices200ResponseItemsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('osVersion', osVersion)
          ..add('deviceModel', deviceModel)
          ..add('lastIp', lastIp)
          ..add('createdAt', createdAt)
          ..add('lastSeenAt', lastSeenAt)
          ..add('revokedAt', revokedAt))
        .toString();
  }
}

class GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminUsersByUserIdDevices200ResponseItemsInner,
            GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder> {
  _$GetAdminUsersByUserIdDevices200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _osVersion;
  String? get osVersion => _$this._osVersion;
  set osVersion(String? osVersion) => _$this._osVersion = osVersion;

  String? _deviceModel;
  String? get deviceModel => _$this._deviceModel;
  set deviceModel(String? deviceModel) => _$this._deviceModel = deviceModel;

  String? _lastIp;
  String? get lastIp => _$this._lastIp;
  set lastIp(String? lastIp) => _$this._lastIp = lastIp;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder() {
    GetAdminUsersByUserIdDevices200ResponseItemsInner._defaults(this);
  }

  GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _osVersion = $v.osVersion;
      _deviceModel = $v.deviceModel;
      _lastIp = $v.lastIp;
      _createdAt = $v.createdAt;
      _lastSeenAt = $v.lastSeenAt;
      _revokedAt = $v.revokedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminUsersByUserIdDevices200ResponseItemsInner other) {
    _$v = other as _$GetAdminUsersByUserIdDevices200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsersByUserIdDevices200ResponseItemsInner build() => _build();

  _$GetAdminUsersByUserIdDevices200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminUsersByUserIdDevices200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminUsersByUserIdDevices200ResponseItemsInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'GetAdminUsersByUserIdDevices200ResponseItemsInner', 'name'),
          platform: BuiltValueNullFieldError.checkNotNull(platform,
              r'GetAdminUsersByUserIdDevices200ResponseItemsInner', 'platform'),
          appVersion: appVersion,
          osVersion: osVersion,
          deviceModel: deviceModel,
          lastIp: lastIp,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'GetAdminUsersByUserIdDevices200ResponseItemsInner',
              'createdAt'),
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
              lastSeenAt,
              r'GetAdminUsersByUserIdDevices200ResponseItemsInner',
              'lastSeenAt'),
          revokedAt: revokedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
