// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_admin_banner_slot_request_revisions_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResetAdminBannerSlotRequestRevisionsInner
    extends ResetAdminBannerSlotRequestRevisionsInner {
  @override
  final String id;
  @override
  final int version;

  factory _$ResetAdminBannerSlotRequestRevisionsInner(
          [void Function(ResetAdminBannerSlotRequestRevisionsInnerBuilder)?
              updates]) =>
      (ResetAdminBannerSlotRequestRevisionsInnerBuilder()..update(updates))
          ._build();

  _$ResetAdminBannerSlotRequestRevisionsInner._(
      {required this.id, required this.version})
      : super._();
  @override
  ResetAdminBannerSlotRequestRevisionsInner rebuild(
          void Function(ResetAdminBannerSlotRequestRevisionsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResetAdminBannerSlotRequestRevisionsInnerBuilder toBuilder() =>
      ResetAdminBannerSlotRequestRevisionsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResetAdminBannerSlotRequestRevisionsInner &&
        id == other.id &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ResetAdminBannerSlotRequestRevisionsInner')
          ..add('id', id)
          ..add('version', version))
        .toString();
  }
}

class ResetAdminBannerSlotRequestRevisionsInnerBuilder
    implements
        Builder<ResetAdminBannerSlotRequestRevisionsInner,
            ResetAdminBannerSlotRequestRevisionsInnerBuilder> {
  _$ResetAdminBannerSlotRequestRevisionsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ResetAdminBannerSlotRequestRevisionsInnerBuilder() {
    ResetAdminBannerSlotRequestRevisionsInner._defaults(this);
  }

  ResetAdminBannerSlotRequestRevisionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResetAdminBannerSlotRequestRevisionsInner other) {
    _$v = other as _$ResetAdminBannerSlotRequestRevisionsInner;
  }

  @override
  void update(
      void Function(ResetAdminBannerSlotRequestRevisionsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ResetAdminBannerSlotRequestRevisionsInner build() => _build();

  _$ResetAdminBannerSlotRequestRevisionsInner _build() {
    final _$result = _$v ??
        _$ResetAdminBannerSlotRequestRevisionsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ResetAdminBannerSlotRequestRevisionsInner', 'id'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'ResetAdminBannerSlotRequestRevisionsInner', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
