// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_users_by_user_id_disable200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminUsersByUserIdDisable200Response
    extends PatchAdminUsersByUserIdDisable200Response {
  @override
  final String id;
  @override
  final String? phoneMasked;
  @override
  final bool isEnabled;

  factory _$PatchAdminUsersByUserIdDisable200Response(
          [void Function(PatchAdminUsersByUserIdDisable200ResponseBuilder)?
              updates]) =>
      (PatchAdminUsersByUserIdDisable200ResponseBuilder()..update(updates))
          ._build();

  _$PatchAdminUsersByUserIdDisable200Response._(
      {required this.id, this.phoneMasked, required this.isEnabled})
      : super._();
  @override
  PatchAdminUsersByUserIdDisable200Response rebuild(
          void Function(PatchAdminUsersByUserIdDisable200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminUsersByUserIdDisable200ResponseBuilder toBuilder() =>
      PatchAdminUsersByUserIdDisable200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminUsersByUserIdDisable200Response &&
        id == other.id &&
        phoneMasked == other.phoneMasked &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PatchAdminUsersByUserIdDisable200Response')
          ..add('id', id)
          ..add('phoneMasked', phoneMasked)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PatchAdminUsersByUserIdDisable200ResponseBuilder
    implements
        Builder<PatchAdminUsersByUserIdDisable200Response,
            PatchAdminUsersByUserIdDisable200ResponseBuilder> {
  _$PatchAdminUsersByUserIdDisable200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PatchAdminUsersByUserIdDisable200ResponseBuilder() {
    PatchAdminUsersByUserIdDisable200Response._defaults(this);
  }

  PatchAdminUsersByUserIdDisable200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _phoneMasked = $v.phoneMasked;
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAdminUsersByUserIdDisable200Response other) {
    _$v = other as _$PatchAdminUsersByUserIdDisable200Response;
  }

  @override
  void update(
      void Function(PatchAdminUsersByUserIdDisable200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminUsersByUserIdDisable200Response build() => _build();

  _$PatchAdminUsersByUserIdDisable200Response _build() {
    final _$result = _$v ??
        _$PatchAdminUsersByUserIdDisable200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PatchAdminUsersByUserIdDisable200Response', 'id'),
          phoneMasked: phoneMasked,
          isEnabled: BuiltValueNullFieldError.checkNotNull(isEnabled,
              r'PatchAdminUsersByUserIdDisable200Response', 'isEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
