// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_admin_banner_slot_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResetAdminBannerSlotRequest extends ResetAdminBannerSlotRequest {
  @override
  final BuiltSet<ResetAdminBannerSlotRequestRevisionsInner> revisions;

  factory _$ResetAdminBannerSlotRequest(
          [void Function(ResetAdminBannerSlotRequestBuilder)? updates]) =>
      (ResetAdminBannerSlotRequestBuilder()..update(updates))._build();

  _$ResetAdminBannerSlotRequest._({required this.revisions}) : super._();
  @override
  ResetAdminBannerSlotRequest rebuild(
          void Function(ResetAdminBannerSlotRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResetAdminBannerSlotRequestBuilder toBuilder() =>
      ResetAdminBannerSlotRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResetAdminBannerSlotRequest && revisions == other.revisions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, revisions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResetAdminBannerSlotRequest')
          ..add('revisions', revisions))
        .toString();
  }
}

class ResetAdminBannerSlotRequestBuilder
    implements
        Builder<ResetAdminBannerSlotRequest,
            ResetAdminBannerSlotRequestBuilder> {
  _$ResetAdminBannerSlotRequest? _$v;

  SetBuilder<ResetAdminBannerSlotRequestRevisionsInner>? _revisions;
  SetBuilder<ResetAdminBannerSlotRequestRevisionsInner> get revisions =>
      _$this._revisions ??=
          SetBuilder<ResetAdminBannerSlotRequestRevisionsInner>();
  set revisions(
          SetBuilder<ResetAdminBannerSlotRequestRevisionsInner>? revisions) =>
      _$this._revisions = revisions;

  ResetAdminBannerSlotRequestBuilder() {
    ResetAdminBannerSlotRequest._defaults(this);
  }

  ResetAdminBannerSlotRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _revisions = $v.revisions.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResetAdminBannerSlotRequest other) {
    _$v = other as _$ResetAdminBannerSlotRequest;
  }

  @override
  void update(void Function(ResetAdminBannerSlotRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResetAdminBannerSlotRequest build() => _build();

  _$ResetAdminBannerSlotRequest _build() {
    _$ResetAdminBannerSlotRequest _$result;
    try {
      _$result = _$v ??
          _$ResetAdminBannerSlotRequest._(
            revisions: revisions.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'revisions';
        revisions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ResetAdminBannerSlotRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
