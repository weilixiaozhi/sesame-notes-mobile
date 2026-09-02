// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_audit_logs200_response_items_inner_target.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAuditLogs200ResponseItemsInnerTarget
    extends GetAdminAuditLogs200ResponseItemsInnerTarget {
  @override
  final String type;
  @override
  final String id;

  factory _$GetAdminAuditLogs200ResponseItemsInnerTarget(
          [void Function(GetAdminAuditLogs200ResponseItemsInnerTargetBuilder)?
              updates]) =>
      (GetAdminAuditLogs200ResponseItemsInnerTargetBuilder()..update(updates))
          ._build();

  _$GetAdminAuditLogs200ResponseItemsInnerTarget._(
      {required this.type, required this.id})
      : super._();
  @override
  GetAdminAuditLogs200ResponseItemsInnerTarget rebuild(
          void Function(GetAdminAuditLogs200ResponseItemsInnerTargetBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAuditLogs200ResponseItemsInnerTargetBuilder toBuilder() =>
      GetAdminAuditLogs200ResponseItemsInnerTargetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAuditLogs200ResponseItemsInnerTarget &&
        type == other.type &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAuditLogs200ResponseItemsInnerTarget')
          ..add('type', type)
          ..add('id', id))
        .toString();
  }
}

class GetAdminAuditLogs200ResponseItemsInnerTargetBuilder
    implements
        Builder<GetAdminAuditLogs200ResponseItemsInnerTarget,
            GetAdminAuditLogs200ResponseItemsInnerTargetBuilder> {
  _$GetAdminAuditLogs200ResponseItemsInnerTarget? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetAdminAuditLogs200ResponseItemsInnerTargetBuilder() {
    GetAdminAuditLogs200ResponseItemsInnerTarget._defaults(this);
  }

  GetAdminAuditLogs200ResponseItemsInnerTargetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAuditLogs200ResponseItemsInnerTarget other) {
    _$v = other as _$GetAdminAuditLogs200ResponseItemsInnerTarget;
  }

  @override
  void update(
      void Function(GetAdminAuditLogs200ResponseItemsInnerTargetBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAuditLogs200ResponseItemsInnerTarget build() => _build();

  _$GetAdminAuditLogs200ResponseItemsInnerTarget _build() {
    final _$result = _$v ??
        _$GetAdminAuditLogs200ResponseItemsInnerTarget._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'GetAdminAuditLogs200ResponseItemsInnerTarget', 'type'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminAuditLogs200ResponseItemsInnerTarget', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
