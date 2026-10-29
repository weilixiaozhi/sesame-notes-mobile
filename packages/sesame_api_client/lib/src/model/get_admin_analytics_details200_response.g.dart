// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_details200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalyticsDetails200Response
    extends GetAdminAnalyticsDetails200Response {
  @override
  final GetAdminAnalytics200ResponseRange range;
  @override
  final GetAdminAnalyticsDetails200ResponseSummary summary;
  @override
  final BuiltList<GetAdminAnalyticsDetails200ResponseSeriesInner> series;
  @override
  final BuiltList<GetAdminAnalyticsDetails200ResponsePagesInner> pages;
  @override
  final BuiltList<GetAdminAnalyticsDetails200ResponseEventsInner> events;
  @override
  final BuiltList<GetAdminAnalyticsDetails200ResponseExposuresInner>? exposures;
  @override
  final GetAdminAnalytics200ResponseCoverage coverage;

  factory _$GetAdminAnalyticsDetails200Response(
          [void Function(GetAdminAnalyticsDetails200ResponseBuilder)?
              updates]) =>
      (GetAdminAnalyticsDetails200ResponseBuilder()..update(updates))._build();

  _$GetAdminAnalyticsDetails200Response._(
      {required this.range,
      required this.summary,
      required this.series,
      required this.pages,
      required this.events,
      this.exposures,
      required this.coverage})
      : super._();
  @override
  GetAdminAnalyticsDetails200Response rebuild(
          void Function(GetAdminAnalyticsDetails200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsDetails200ResponseBuilder toBuilder() =>
      GetAdminAnalyticsDetails200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsDetails200Response &&
        range == other.range &&
        summary == other.summary &&
        series == other.series &&
        pages == other.pages &&
        events == other.events &&
        exposures == other.exposures &&
        coverage == other.coverage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, series.hashCode);
    _$hash = $jc(_$hash, pages.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, exposures.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalyticsDetails200Response')
          ..add('range', range)
          ..add('summary', summary)
          ..add('series', series)
          ..add('pages', pages)
          ..add('events', events)
          ..add('exposures', exposures)
          ..add('coverage', coverage))
        .toString();
  }
}

class GetAdminAnalyticsDetails200ResponseBuilder
    implements
        Builder<GetAdminAnalyticsDetails200Response,
            GetAdminAnalyticsDetails200ResponseBuilder> {
  _$GetAdminAnalyticsDetails200Response? _$v;

  GetAdminAnalytics200ResponseRangeBuilder? _range;
  GetAdminAnalytics200ResponseRangeBuilder get range =>
      _$this._range ??= GetAdminAnalytics200ResponseRangeBuilder();
  set range(GetAdminAnalytics200ResponseRangeBuilder? range) =>
      _$this._range = range;

  GetAdminAnalyticsDetails200ResponseSummaryBuilder? _summary;
  GetAdminAnalyticsDetails200ResponseSummaryBuilder get summary =>
      _$this._summary ??= GetAdminAnalyticsDetails200ResponseSummaryBuilder();
  set summary(GetAdminAnalyticsDetails200ResponseSummaryBuilder? summary) =>
      _$this._summary = summary;

  ListBuilder<GetAdminAnalyticsDetails200ResponseSeriesInner>? _series;
  ListBuilder<GetAdminAnalyticsDetails200ResponseSeriesInner> get series =>
      _$this._series ??=
          ListBuilder<GetAdminAnalyticsDetails200ResponseSeriesInner>();
  set series(
          ListBuilder<GetAdminAnalyticsDetails200ResponseSeriesInner>?
              series) =>
      _$this._series = series;

  ListBuilder<GetAdminAnalyticsDetails200ResponsePagesInner>? _pages;
  ListBuilder<GetAdminAnalyticsDetails200ResponsePagesInner> get pages =>
      _$this._pages ??=
          ListBuilder<GetAdminAnalyticsDetails200ResponsePagesInner>();
  set pages(
          ListBuilder<GetAdminAnalyticsDetails200ResponsePagesInner>? pages) =>
      _$this._pages = pages;

  ListBuilder<GetAdminAnalyticsDetails200ResponseEventsInner>? _events;
  ListBuilder<GetAdminAnalyticsDetails200ResponseEventsInner> get events =>
      _$this._events ??=
          ListBuilder<GetAdminAnalyticsDetails200ResponseEventsInner>();
  set events(
          ListBuilder<GetAdminAnalyticsDetails200ResponseEventsInner>?
              events) =>
      _$this._events = events;

  ListBuilder<GetAdminAnalyticsDetails200ResponseExposuresInner>? _exposures;
  ListBuilder<GetAdminAnalyticsDetails200ResponseExposuresInner>
      get exposures => _$this._exposures ??=
          ListBuilder<GetAdminAnalyticsDetails200ResponseExposuresInner>();
  set exposures(
          ListBuilder<GetAdminAnalyticsDetails200ResponseExposuresInner>?
              exposures) =>
      _$this._exposures = exposures;

  GetAdminAnalytics200ResponseCoverageBuilder? _coverage;
  GetAdminAnalytics200ResponseCoverageBuilder get coverage =>
      _$this._coverage ??= GetAdminAnalytics200ResponseCoverageBuilder();
  set coverage(GetAdminAnalytics200ResponseCoverageBuilder? coverage) =>
      _$this._coverage = coverage;

  GetAdminAnalyticsDetails200ResponseBuilder() {
    GetAdminAnalyticsDetails200Response._defaults(this);
  }

  GetAdminAnalyticsDetails200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _summary = $v.summary.toBuilder();
      _series = $v.series.toBuilder();
      _pages = $v.pages.toBuilder();
      _events = $v.events.toBuilder();
      _exposures = $v.exposures?.toBuilder();
      _coverage = $v.coverage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsDetails200Response other) {
    _$v = other as _$GetAdminAnalyticsDetails200Response;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsDetails200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsDetails200Response build() => _build();

  _$GetAdminAnalyticsDetails200Response _build() {
    _$GetAdminAnalyticsDetails200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminAnalyticsDetails200Response._(
            range: range.build(),
            summary: summary.build(),
            series: series.build(),
            pages: pages.build(),
            events: events.build(),
            exposures: _exposures?.build(),
            coverage: coverage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'range';
        range.build();
        _$failedField = 'summary';
        summary.build();
        _$failedField = 'series';
        series.build();
        _$failedField = 'pages';
        pages.build();
        _$failedField = 'events';
        events.build();
        _$failedField = 'exposures';
        _exposures?.build();
        _$failedField = 'coverage';
        coverage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GetAdminAnalyticsDetails200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
