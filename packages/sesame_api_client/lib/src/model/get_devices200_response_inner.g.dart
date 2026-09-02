// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_devices200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetDevices200ResponseInner extends GetDevices200ResponseInner {
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
  final DateTime lastSeenAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? revokedAt;
  @override
  final bool current;

  factory _$GetDevices200ResponseInner(
          [void Function(GetDevices200ResponseInnerBuilder)? updates]) =>
      (GetDevices200ResponseInnerBuilder()..update(updates))._build();

  _$GetDevices200ResponseInner._(
      {required this.id,
      required this.name,
      required this.platform,
      this.appVersion,
      this.osVersion,
      this.deviceModel,
      required this.lastSeenAt,
      required this.createdAt,
      this.revokedAt,
      required this.current})
      : super._();
  @override
  GetDevices200ResponseInner rebuild(
          void Function(GetDevices200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetDevices200ResponseInnerBuilder toBuilder() =>
      GetDevices200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetDevices200ResponseInner &&
        id == other.id &&
        name == other.name &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        osVersion == other.osVersion &&
        deviceModel == other.deviceModel &&
        lastSeenAt == other.lastSeenAt &&
        createdAt == other.createdAt &&
        revokedAt == other.revokedAt &&
        current == other.current;
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
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, revokedAt.hashCode);
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetDevices200ResponseInner')
          ..add('id', id)
          ..add('name', name)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('osVersion', osVersion)
          ..add('deviceModel', deviceModel)
          ..add('lastSeenAt', lastSeenAt)
          ..add('createdAt', createdAt)
          ..add('revokedAt', revokedAt)
          ..add('current', current))
        .toString();
  }
}

class GetDevices200ResponseInnerBuilder
    implements
        Builder<GetDevices200ResponseInner, GetDevices200ResponseInnerBuilder> {
  _$GetDevices200ResponseInner? _$v;

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

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _revokedAt;
  DateTime? get revokedAt => _$this._revokedAt;
  set revokedAt(DateTime? revokedAt) => _$this._revokedAt = revokedAt;

  bool? _current;
  bool? get current => _$this._current;
  set current(bool? current) => _$this._current = current;

  GetDevices200ResponseInnerBuilder() {
    GetDevices200ResponseInner._defaults(this);
  }

  GetDevices200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _osVersion = $v.osVersion;
      _deviceModel = $v.deviceModel;
      _lastSeenAt = $v.lastSeenAt;
      _createdAt = $v.createdAt;
      _revokedAt = $v.revokedAt;
      _current = $v.current;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetDevices200ResponseInner other) {
    _$v = other as _$GetDevices200ResponseInner;
  }

  @override
  void update(void Function(GetDevices200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetDevices200ResponseInner build() => _build();

  _$GetDevices200ResponseInner _build() {
    final _$result = _$v ??
        _$GetDevices200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetDevices200ResponseInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetDevices200ResponseInner', 'name'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'GetDevices200ResponseInner', 'platform'),
          appVersion: appVersion,
          osVersion: osVersion,
          deviceModel: deviceModel,
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
              lastSeenAt, r'GetDevices200ResponseInner', 'lastSeenAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'GetDevices200ResponseInner', 'createdAt'),
          revokedAt: revokedAt,
          current: BuiltValueNullFieldError.checkNotNull(
              current, r'GetDevices200ResponseInner', 'current'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
