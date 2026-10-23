// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics200_response_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalytics200ResponseSummary
    extends GetAdminAnalytics200ResponseSummary {
  @override
  final int newUsers;
  @override
  final int activeUsers;
  @override
  final int pageViews;

  factory _$GetAdminAnalytics200ResponseSummary(
          [void Function(GetAdminAnalytics200ResponseSummaryBuilder)?
              updates]) =>
      (GetAdminAnalytics200ResponseSummaryBuilder()..update(updates))._build();

  _$GetAdminAnalytics200ResponseSummary._(
      {required this.newUsers,
      required this.activeUsers,
      required this.pageViews})
      : super._();
  @override
  GetAdminAnalytics200ResponseSummary rebuild(
          void Function(GetAdminAnalytics200ResponseSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalytics200ResponseSummaryBuilder toBuilder() =>
      GetAdminAnalytics200ResponseSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalytics200ResponseSummary &&
        newUsers == other.newUsers &&
        activeUsers == other.activeUsers &&
        pageViews == other.pageViews;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newUsers.hashCode);
    _$hash = $jc(_$hash, activeUsers.hashCode);
    _$hash = $jc(_$hash, pageViews.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalytics200ResponseSummary')
          ..add('newUsers', newUsers)
          ..add('activeUsers', activeUsers)
          ..add('pageViews', pageViews))
        .toString();
  }
}

class GetAdminAnalytics200ResponseSummaryBuilder
    implements
        Builder<GetAdminAnalytics200ResponseSummary,
            GetAdminAnalytics200ResponseSummaryBuilder> {
  _$GetAdminAnalytics200ResponseSummary? _$v;

  int? _newUsers;
  int? get newUsers => _$this._newUsers;
  set newUsers(int? newUsers) => _$this._newUsers = newUsers;

  int? _activeUsers;
  int? get activeUsers => _$this._activeUsers;
  set activeUsers(int? activeUsers) => _$this._activeUsers = activeUsers;

  int? _pageViews;
  int? get pageViews => _$this._pageViews;
  set pageViews(int? pageViews) => _$this._pageViews = pageViews;

  GetAdminAnalytics200ResponseSummaryBuilder() {
    GetAdminAnalytics200ResponseSummary._defaults(this);
  }

  GetAdminAnalytics200ResponseSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newUsers = $v.newUsers;
      _activeUsers = $v.activeUsers;
      _pageViews = $v.pageViews;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalytics200ResponseSummary other) {
    _$v = other as _$GetAdminAnalytics200ResponseSummary;
  }

  @override
  void update(
      void Function(GetAdminAnalytics200ResponseSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalytics200ResponseSummary build() => _build();

  _$GetAdminAnalytics200ResponseSummary _build() {
    final _$result = _$v ??
        _$GetAdminAnalytics200ResponseSummary._(
          newUsers: BuiltValueNullFieldError.checkNotNull(
              newUsers, r'GetAdminAnalytics200ResponseSummary', 'newUsers'),
          activeUsers: BuiltValueNullFieldError.checkNotNull(activeUsers,
              r'GetAdminAnalytics200ResponseSummary', 'activeUsers'),
          pageViews: BuiltValueNullFieldError.checkNotNull(
              pageViews, r'GetAdminAnalytics200ResponseSummary', 'pageViews'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
