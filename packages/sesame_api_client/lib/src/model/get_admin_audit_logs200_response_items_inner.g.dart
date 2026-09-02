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
  final String actor;
  @override
  final String action;
  @override
  final GetAdminAuditLogs200ResponseItemsInnerTarget target;
  @override
  final String requestId;
  @override
  final String? ip;
  @override
  final DateTime createdAt;

  factory _$GetAdminAuditLogs200ResponseItemsInner(
          [void Function(GetAdminAuditLogs200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminAuditLogs200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAuditLogs200ResponseItemsInner._(
      {required this.id,
      required this.actor,
      required this.action,
      required this.target,
      required this.requestId,
      this.ip,
      required this.createdAt})
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
        actor == other.actor &&
        action == other.action &&
        target == other.target &&
        requestId == other.requestId &&
        ip == other.ip &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, ip.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAuditLogs200ResponseItemsInner')
          ..add('id', id)
          ..add('actor', actor)
          ..add('action', action)
          ..add('target', target)
          ..add('requestId', requestId)
          ..add('ip', ip)
          ..add('createdAt', createdAt))
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

  String? _actor;
  String? get actor => _$this._actor;
  set actor(String? actor) => _$this._actor = actor;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  GetAdminAuditLogs200ResponseItemsInnerTargetBuilder? _target;
  GetAdminAuditLogs200ResponseItemsInnerTargetBuilder get target =>
      _$this._target ??= GetAdminAuditLogs200ResponseItemsInnerTargetBuilder();
  set target(GetAdminAuditLogs200ResponseItemsInnerTargetBuilder? target) =>
      _$this._target = target;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  String? _ip;
  String? get ip => _$this._ip;
  set ip(String? ip) => _$this._ip = ip;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  GetAdminAuditLogs200ResponseItemsInnerBuilder() {
    GetAdminAuditLogs200ResponseItemsInner._defaults(this);
  }

  GetAdminAuditLogs200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _actor = $v.actor;
      _action = $v.action;
      _target = $v.target.toBuilder();
      _requestId = $v.requestId;
      _ip = $v.ip;
      _createdAt = $v.createdAt;
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
    _$GetAdminAuditLogs200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminAuditLogs200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetAdminAuditLogs200ResponseItemsInner', 'id'),
            actor: BuiltValueNullFieldError.checkNotNull(
                actor, r'GetAdminAuditLogs200ResponseItemsInner', 'actor'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'GetAdminAuditLogs200ResponseItemsInner', 'action'),
            target: target.build(),
            requestId: BuiltValueNullFieldError.checkNotNull(requestId,
                r'GetAdminAuditLogs200ResponseItemsInner', 'requestId'),
            ip: ip,
            createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
                r'GetAdminAuditLogs200ResponseItemsInner', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'target';
        target.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminAuditLogs200ResponseItemsInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
