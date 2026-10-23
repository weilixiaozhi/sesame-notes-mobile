// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_details200_response_series_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalyticsDetails200ResponseSeriesInner
    extends GetAdminAnalyticsDetails200ResponseSeriesInner {
  @override
  final DateTime periodStart;
  @override
  final int pageViews;
  @override
  final int visitors;
  @override
  final int clicks;
  @override
  final int clickUsers;
  @override
  final int completions;
  @override
  final int completionUsers;

  factory _$GetAdminAnalyticsDetails200ResponseSeriesInner(
          [void Function(GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAnalyticsDetails200ResponseSeriesInner._(
      {required this.periodStart,
      required this.pageViews,
      required this.visitors,
      required this.clicks,
      required this.clickUsers,
      required this.completions,
      required this.completionUsers})
      : super._();
  @override
  GetAdminAnalyticsDetails200ResponseSeriesInner rebuild(
          void Function(GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder toBuilder() =>
      GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsDetails200ResponseSeriesInner &&
        periodStart == other.periodStart &&
        pageViews == other.pageViews &&
        visitors == other.visitors &&
        clicks == other.clicks &&
        clickUsers == other.clickUsers &&
        completions == other.completions &&
        completionUsers == other.completionUsers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, periodStart.hashCode);
    _$hash = $jc(_$hash, pageViews.hashCode);
    _$hash = $jc(_$hash, visitors.hashCode);
    _$hash = $jc(_$hash, clicks.hashCode);
    _$hash = $jc(_$hash, clickUsers.hashCode);
    _$hash = $jc(_$hash, completions.hashCode);
    _$hash = $jc(_$hash, completionUsers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsDetails200ResponseSeriesInner')
          ..add('periodStart', periodStart)
          ..add('pageViews', pageViews)
          ..add('visitors', visitors)
          ..add('clicks', clicks)
          ..add('clickUsers', clickUsers)
          ..add('completions', completions)
          ..add('completionUsers', completionUsers))
        .toString();
  }
}

class GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder
    implements
        Builder<GetAdminAnalyticsDetails200ResponseSeriesInner,
            GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder> {
  _$GetAdminAnalyticsDetails200ResponseSeriesInner? _$v;

  DateTime? _periodStart;
  DateTime? get periodStart => _$this._periodStart;
  set periodStart(DateTime? periodStart) => _$this._periodStart = periodStart;

  int? _pageViews;
  int? get pageViews => _$this._pageViews;
  set pageViews(int? pageViews) => _$this._pageViews = pageViews;

  int? _visitors;
  int? get visitors => _$this._visitors;
  set visitors(int? visitors) => _$this._visitors = visitors;

  int? _clicks;
  int? get clicks => _$this._clicks;
  set clicks(int? clicks) => _$this._clicks = clicks;

  int? _clickUsers;
  int? get clickUsers => _$this._clickUsers;
  set clickUsers(int? clickUsers) => _$this._clickUsers = clickUsers;

  int? _completions;
  int? get completions => _$this._completions;
  set completions(int? completions) => _$this._completions = completions;

  int? _completionUsers;
  int? get completionUsers => _$this._completionUsers;
  set completionUsers(int? completionUsers) =>
      _$this._completionUsers = completionUsers;

  GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder() {
    GetAdminAnalyticsDetails200ResponseSeriesInner._defaults(this);
  }

  GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _periodStart = $v.periodStart;
      _pageViews = $v.pageViews;
      _visitors = $v.visitors;
      _clicks = $v.clicks;
      _clickUsers = $v.clickUsers;
      _completions = $v.completions;
      _completionUsers = $v.completionUsers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsDetails200ResponseSeriesInner other) {
    _$v = other as _$GetAdminAnalyticsDetails200ResponseSeriesInner;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsDetails200ResponseSeriesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsDetails200ResponseSeriesInner build() => _build();

  _$GetAdminAnalyticsDetails200ResponseSeriesInner _build() {
    final _$result = _$v ??
        _$GetAdminAnalyticsDetails200ResponseSeriesInner._(
          periodStart: BuiltValueNullFieldError.checkNotNull(periodStart,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'periodStart'),
          pageViews: BuiltValueNullFieldError.checkNotNull(pageViews,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'pageViews'),
          visitors: BuiltValueNullFieldError.checkNotNull(visitors,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'visitors'),
          clicks: BuiltValueNullFieldError.checkNotNull(clicks,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'clicks'),
          clickUsers: BuiltValueNullFieldError.checkNotNull(clickUsers,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'clickUsers'),
          completions: BuiltValueNullFieldError.checkNotNull(completions,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner', 'completions'),
          completionUsers: BuiltValueNullFieldError.checkNotNull(
              completionUsers,
              r'GetAdminAnalyticsDetails200ResponseSeriesInner',
              'completionUsers'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
