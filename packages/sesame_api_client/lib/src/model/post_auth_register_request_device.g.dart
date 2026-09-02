// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_register_request_device.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthRegisterRequestDevice extends PostAuthRegisterRequestDevice {
  @override
  final String installationId;
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

  factory _$PostAuthRegisterRequestDevice(
          [void Function(PostAuthRegisterRequestDeviceBuilder)? updates]) =>
      (PostAuthRegisterRequestDeviceBuilder()..update(updates))._build();

  _$PostAuthRegisterRequestDevice._(
      {required this.installationId,
      required this.name,
      required this.platform,
      this.appVersion,
      this.osVersion,
      this.deviceModel})
      : super._();
  @override
  PostAuthRegisterRequestDevice rebuild(
          void Function(PostAuthRegisterRequestDeviceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthRegisterRequestDeviceBuilder toBuilder() =>
      PostAuthRegisterRequestDeviceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthRegisterRequestDevice &&
        installationId == other.installationId &&
        name == other.name &&
        platform == other.platform &&
        appVersion == other.appVersion &&
        osVersion == other.osVersion &&
        deviceModel == other.deviceModel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, installationId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, osVersion.hashCode);
    _$hash = $jc(_$hash, deviceModel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthRegisterRequestDevice')
          ..add('installationId', installationId)
          ..add('name', name)
          ..add('platform', platform)
          ..add('appVersion', appVersion)
          ..add('osVersion', osVersion)
          ..add('deviceModel', deviceModel))
        .toString();
  }
}

class PostAuthRegisterRequestDeviceBuilder
    implements
        Builder<PostAuthRegisterRequestDevice,
            PostAuthRegisterRequestDeviceBuilder> {
  _$PostAuthRegisterRequestDevice? _$v;

  String? _installationId;
  String? get installationId => _$this._installationId;
  set installationId(String? installationId) =>
      _$this._installationId = installationId;

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

  PostAuthRegisterRequestDeviceBuilder() {
    PostAuthRegisterRequestDevice._defaults(this);
  }

  PostAuthRegisterRequestDeviceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _installationId = $v.installationId;
      _name = $v.name;
      _platform = $v.platform;
      _appVersion = $v.appVersion;
      _osVersion = $v.osVersion;
      _deviceModel = $v.deviceModel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthRegisterRequestDevice other) {
    _$v = other as _$PostAuthRegisterRequestDevice;
  }

  @override
  void update(void Function(PostAuthRegisterRequestDeviceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthRegisterRequestDevice build() => _build();

  _$PostAuthRegisterRequestDevice _build() {
    final _$result = _$v ??
        _$PostAuthRegisterRequestDevice._(
          installationId: BuiltValueNullFieldError.checkNotNull(installationId,
              r'PostAuthRegisterRequestDevice', 'installationId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostAuthRegisterRequestDevice', 'name'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PostAuthRegisterRequestDevice', 'platform'),
          appVersion: appVersion,
          osVersion: osVersion,
          deviceModel: deviceModel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
