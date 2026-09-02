// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminUsers200ResponseItemsInner
    extends GetAdminUsers200ResponseItemsInner {
  @override
  final String id;
  @override
  final String? phoneMasked;
  @override
  final String? sesameNumber;
  @override
  final bool isAdmin;
  @override
  final bool isEnabled;
  @override
  final DateTime createdAt;
  @override
  final int deviceCount;

  factory _$GetAdminUsers200ResponseItemsInner(
          [void Function(GetAdminUsers200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminUsers200ResponseItemsInnerBuilder()..update(updates))._build();

  _$GetAdminUsers200ResponseItemsInner._(
      {required this.id,
      this.phoneMasked,
      this.sesameNumber,
      required this.isAdmin,
      required this.isEnabled,
      required this.createdAt,
      required this.deviceCount})
      : super._();
  @override
  GetAdminUsers200ResponseItemsInner rebuild(
          void Function(GetAdminUsers200ResponseItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsers200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminUsers200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsers200ResponseItemsInner &&
        id == other.id &&
        phoneMasked == other.phoneMasked &&
        sesameNumber == other.sesameNumber &&
        isAdmin == other.isAdmin &&
        isEnabled == other.isEnabled &&
        createdAt == other.createdAt &&
        deviceCount == other.deviceCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, isAdmin.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, deviceCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminUsers200ResponseItemsInner')
          ..add('id', id)
          ..add('phoneMasked', phoneMasked)
          ..add('sesameNumber', sesameNumber)
          ..add('isAdmin', isAdmin)
          ..add('isEnabled', isEnabled)
          ..add('createdAt', createdAt)
          ..add('deviceCount', deviceCount))
        .toString();
  }
}

class GetAdminUsers200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminUsers200ResponseItemsInner,
            GetAdminUsers200ResponseItemsInnerBuilder> {
  _$GetAdminUsers200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  String? _sesameNumber;
  String? get sesameNumber => _$this._sesameNumber;
  set sesameNumber(String? sesameNumber) => _$this._sesameNumber = sesameNumber;

  bool? _isAdmin;
  bool? get isAdmin => _$this._isAdmin;
  set isAdmin(bool? isAdmin) => _$this._isAdmin = isAdmin;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _deviceCount;
  int? get deviceCount => _$this._deviceCount;
  set deviceCount(int? deviceCount) => _$this._deviceCount = deviceCount;

  GetAdminUsers200ResponseItemsInnerBuilder() {
    GetAdminUsers200ResponseItemsInner._defaults(this);
  }

  GetAdminUsers200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _phoneMasked = $v.phoneMasked;
      _sesameNumber = $v.sesameNumber;
      _isAdmin = $v.isAdmin;
      _isEnabled = $v.isEnabled;
      _createdAt = $v.createdAt;
      _deviceCount = $v.deviceCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminUsers200ResponseItemsInner other) {
    _$v = other as _$GetAdminUsers200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminUsers200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsers200ResponseItemsInner build() => _build();

  _$GetAdminUsers200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminUsers200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminUsers200ResponseItemsInner', 'id'),
          phoneMasked: phoneMasked,
          sesameNumber: sesameNumber,
          isAdmin: BuiltValueNullFieldError.checkNotNull(
              isAdmin, r'GetAdminUsers200ResponseItemsInner', 'isAdmin'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(
              isEnabled, r'GetAdminUsers200ResponseItemsInner', 'isEnabled'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'GetAdminUsers200ResponseItemsInner', 'createdAt'),
          deviceCount: BuiltValueNullFieldError.checkNotNull(deviceCount,
              r'GetAdminUsers200ResponseItemsInner', 'deviceCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
