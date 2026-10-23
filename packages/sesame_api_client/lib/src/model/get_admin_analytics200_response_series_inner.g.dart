// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics200_response_series_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalytics200ResponseSeriesInner
    extends GetAdminAnalytics200ResponseSeriesInner {
  @override
  final DateTime periodStart;
  @override
  final int newUsers;
  @override
  final int activeUsers;
  @override
  final int pageViews;

  factory _$GetAdminAnalytics200ResponseSeriesInner(
          [void Function(GetAdminAnalytics200ResponseSeriesInnerBuilder)?
              updates]) =>
      (GetAdminAnalytics200ResponseSeriesInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAnalytics200ResponseSeriesInner._(
      {required this.periodStart,
      required this.newUsers,
      required this.activeUsers,
      required this.pageViews})
      : super._();
  @override
  GetAdminAnalytics200ResponseSeriesInner rebuild(
          void Function(GetAdminAnalytics200ResponseSeriesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalytics200ResponseSeriesInnerBuilder toBuilder() =>
      GetAdminAnalytics200ResponseSeriesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalytics200ResponseSeriesInner &&
        periodStart == other.periodStart &&
        newUsers == other.newUsers &&
        activeUsers == other.activeUsers &&
        pageViews == other.pageViews;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, periodStart.hashCode);
    _$hash = $jc(_$hash, newUsers.hashCode);
    _$hash = $jc(_$hash, activeUsers.hashCode);
    _$hash = $jc(_$hash, pageViews.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalytics200ResponseSeriesInner')
          ..add('periodStart', periodStart)
          ..add('newUsers', newUsers)
          ..add('activeUsers', activeUsers)
          ..add('pageViews', pageViews))
        .toString();
  }
}

class GetAdminAnalytics200ResponseSeriesInnerBuilder
    implements
        Builder<GetAdminAnalytics200ResponseSeriesInner,
            GetAdminAnalytics200ResponseSeriesInnerBuilder> {
  _$GetAdminAnalytics200ResponseSeriesInner? _$v;

  DateTime? _periodStart;
  DateTime? get periodStart => _$this._periodStart;
  set periodStart(DateTime? periodStart) => _$this._periodStart = periodStart;

  int? _newUsers;
  int? get newUsers => _$this._newUsers;
  set newUsers(int? newUsers) => _$this._newUsers = newUsers;

  int? _activeUsers;
  int? get activeUsers => _$this._activeUsers;
  set activeUsers(int? activeUsers) => _$this._activeUsers = activeUsers;

  int? _pageViews;
  int? get pageViews => _$this._pageViews;
  set pageViews(int? pageViews) => _$this._pageViews = pageViews;

  GetAdminAnalytics200ResponseSeriesInnerBuilder() {
    GetAdminAnalytics200ResponseSeriesInner._defaults(this);
  }

  GetAdminAnalytics200ResponseSeriesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _periodStart = $v.periodStart;
      _newUsers = $v.newUsers;
      _activeUsers = $v.activeUsers;
      _pageViews = $v.pageViews;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalytics200ResponseSeriesInner other) {
    _$v = other as _$GetAdminAnalytics200ResponseSeriesInner;
  }

  @override
  void update(
      void Function(GetAdminAnalytics200ResponseSeriesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalytics200ResponseSeriesInner build() => _build();

  _$GetAdminAnalytics200ResponseSeriesInner _build() {
    final _$result = _$v ??
        _$GetAdminAnalytics200ResponseSeriesInner._(
          periodStart: BuiltValueNullFieldError.checkNotNull(periodStart,
              r'GetAdminAnalytics200ResponseSeriesInner', 'periodStart'),
          newUsers: BuiltValueNullFieldError.checkNotNull(
              newUsers, r'GetAdminAnalytics200ResponseSeriesInner', 'newUsers'),
          activeUsers: BuiltValueNullFieldError.checkNotNull(activeUsers,
              r'GetAdminAnalytics200ResponseSeriesInner', 'activeUsers'),
          pageViews: BuiltValueNullFieldError.checkNotNull(pageViews,
              r'GetAdminAnalytics200ResponseSeriesInner', 'pageViews'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
