// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_details200_response_exposures_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalyticsDetails200ResponseExposuresInner
    extends GetAdminAnalyticsDetails200ResponseExposuresInner {
  @override
  final String eventName;
  @override
  final String name;
  @override
  final int total;
  @override
  final int users;

  factory _$GetAdminAnalyticsDetails200ResponseExposuresInner(
          [void Function(
                  GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminAnalyticsDetails200ResponseExposuresInner._(
      {required this.eventName,
      required this.name,
      required this.total,
      required this.users})
      : super._();
  @override
  GetAdminAnalyticsDetails200ResponseExposuresInner rebuild(
          void Function(
                  GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder toBuilder() =>
      GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsDetails200ResponseExposuresInner &&
        eventName == other.eventName &&
        name == other.name &&
        total == other.total &&
        users == other.users;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, eventName.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsDetails200ResponseExposuresInner')
          ..add('eventName', eventName)
          ..add('name', name)
          ..add('total', total)
          ..add('users', users))
        .toString();
  }
}

class GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder
    implements
        Builder<GetAdminAnalyticsDetails200ResponseExposuresInner,
            GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder> {
  _$GetAdminAnalyticsDetails200ResponseExposuresInner? _$v;

  String? _eventName;
  String? get eventName => _$this._eventName;
  set eventName(String? eventName) => _$this._eventName = eventName;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _users;
  int? get users => _$this._users;
  set users(int? users) => _$this._users = users;

  GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder() {
    GetAdminAnalyticsDetails200ResponseExposuresInner._defaults(this);
  }

  GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _eventName = $v.eventName;
      _name = $v.name;
      _total = $v.total;
      _users = $v.users;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsDetails200ResponseExposuresInner other) {
    _$v = other as _$GetAdminAnalyticsDetails200ResponseExposuresInner;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsDetails200ResponseExposuresInner build() => _build();

  _$GetAdminAnalyticsDetails200ResponseExposuresInner _build() {
    final _$result = _$v ??
        _$GetAdminAnalyticsDetails200ResponseExposuresInner._(
          eventName: BuiltValueNullFieldError.checkNotNull(
              eventName,
              r'GetAdminAnalyticsDetails200ResponseExposuresInner',
              'eventName'),
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'GetAdminAnalyticsDetails200ResponseExposuresInner', 'name'),
          total: BuiltValueNullFieldError.checkNotNull(total,
              r'GetAdminAnalyticsDetails200ResponseExposuresInner', 'total'),
          users: BuiltValueNullFieldError.checkNotNull(users,
              r'GetAdminAnalyticsDetails200ResponseExposuresInner', 'users'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
