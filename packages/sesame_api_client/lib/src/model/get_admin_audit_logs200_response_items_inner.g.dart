// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_audit_logs200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAuditLogs200ResponseItemsInner
    extends GetAdminAuditLogs200ResponseItemsInner {
  @override
  final String id;
  @override
  final String? ip;
  @override
  final DateTime createdAt;
  @override
  final String actionLabel;
  @override
  final String? actorDisplay;
  @override
  final String? targetDisplay;
  @override
  final String? summary;
  @override
  final String? reason;

  factory _$GetAdminAuditLogs200ResponseItemsInner(
          [void Function(GetAdminAuditLogs200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminAuditLogs200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAuditLogs200ResponseItemsInner._(
      {required this.id,
      this.ip,
      required this.createdAt,
      required this.actionLabel,
      this.actorDisplay,
      this.targetDisplay,
      this.summary,
      this.reason})
      : super._();
  @override
  GetAdminAuditLogs200ResponseItemsInner rebuild(
          void Function(GetAdminAuditLogs200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAuditLogs200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminAuditLogs200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAuditLogs200ResponseItemsInner &&
        id == other.id &&
        ip == other.ip &&
        createdAt == other.createdAt &&
        actionLabel == other.actionLabel &&
        actorDisplay == other.actorDisplay &&
        targetDisplay == other.targetDisplay &&
        summary == other.summary &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ip.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, actionLabel.hashCode);
    _$hash = $jc(_$hash, actorDisplay.hashCode);
    _$hash = $jc(_$hash, targetDisplay.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAuditLogs200ResponseItemsInner')
          ..add('id', id)
          ..add('ip', ip)
          ..add('createdAt', createdAt)
          ..add('actionLabel', actionLabel)
          ..add('actorDisplay', actorDisplay)
          ..add('targetDisplay', targetDisplay)
          ..add('summary', summary)
          ..add('reason', reason))
        .toString();
  }
}

class GetAdminAuditLogs200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminAuditLogs200ResponseItemsInner,
            GetAdminAuditLogs200ResponseItemsInnerBuilder> {
  _$GetAdminAuditLogs200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ip;
  String? get ip => _$this._ip;
  set ip(String? ip) => _$this._ip = ip;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _actionLabel;
  String? get actionLabel => _$this._actionLabel;
  set actionLabel(String? actionLabel) => _$this._actionLabel = actionLabel;

  String? _actorDisplay;
  String? get actorDisplay => _$this._actorDisplay;
  set actorDisplay(String? actorDisplay) => _$this._actorDisplay = actorDisplay;

  String? _targetDisplay;
  String? get targetDisplay => _$this._targetDisplay;
  set targetDisplay(String? targetDisplay) =>
      _$this._targetDisplay = targetDisplay;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GetAdminAuditLogs200ResponseItemsInnerBuilder() {
    GetAdminAuditLogs200ResponseItemsInner._defaults(this);
  }

  GetAdminAuditLogs200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ip = $v.ip;
      _createdAt = $v.createdAt;
      _actionLabel = $v.actionLabel;
      _actorDisplay = $v.actorDisplay;
      _targetDisplay = $v.targetDisplay;
      _summary = $v.summary;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAuditLogs200ResponseItemsInner other) {
    _$v = other as _$GetAdminAuditLogs200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminAuditLogs200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAuditLogs200ResponseItemsInner build() => _build();

  _$GetAdminAuditLogs200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminAuditLogs200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminAuditLogs200ResponseItemsInner', 'id'),
          ip: ip,
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'GetAdminAuditLogs200ResponseItemsInner', 'createdAt'),
          actionLabel: BuiltValueNullFieldError.checkNotNull(actionLabel,
              r'GetAdminAuditLogs200ResponseItemsInner', 'actionLabel'),
          actorDisplay: actorDisplay,
          targetDisplay: targetDisplay,
          summary: summary,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
