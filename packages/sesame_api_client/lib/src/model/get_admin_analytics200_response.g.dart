// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalytics200Response extends GetAdminAnalytics200Response {
  @override
  final GetAdminAnalytics200ResponseRange range;
  @override
  final GetAdminAnalytics200ResponseSummary summary;
  @override
  final BuiltList<GetAdminAnalytics200ResponseSeriesInner> series;
  @override
  final GetAdminAnalytics200ResponseCoverage coverage;

  factory _$GetAdminAnalytics200Response(
          [void Function(GetAdminAnalytics200ResponseBuilder)? updates]) =>
      (GetAdminAnalytics200ResponseBuilder()..update(updates))._build();

  _$GetAdminAnalytics200Response._(
      {required this.range,
      required this.summary,
      required this.series,
      required this.coverage})
      : super._();
  @override
  GetAdminAnalytics200Response rebuild(
          void Function(GetAdminAnalytics200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalytics200ResponseBuilder toBuilder() =>
      GetAdminAnalytics200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalytics200Response &&
        range == other.range &&
        summary == other.summary &&
        series == other.series &&
        coverage == other.coverage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, series.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalytics200Response')
          ..add('range', range)
          ..add('summary', summary)
          ..add('series', series)
          ..add('coverage', coverage))
        .toString();
  }
}

class GetAdminAnalytics200ResponseBuilder
    implements
        Builder<GetAdminAnalytics200Response,
            GetAdminAnalytics200ResponseBuilder> {
  _$GetAdminAnalytics200Response? _$v;

  GetAdminAnalytics200ResponseRangeBuilder? _range;
  GetAdminAnalytics200ResponseRangeBuilder get range =>
      _$this._range ??= GetAdminAnalytics200ResponseRangeBuilder();
  set range(GetAdminAnalytics200ResponseRangeBuilder? range) =>
      _$this._range = range;

  GetAdminAnalytics200ResponseSummaryBuilder? _summary;
  GetAdminAnalytics200ResponseSummaryBuilder get summary =>
      _$this._summary ??= GetAdminAnalytics200ResponseSummaryBuilder();
  set summary(GetAdminAnalytics200ResponseSummaryBuilder? summary) =>
      _$this._summary = summary;

  ListBuilder<GetAdminAnalytics200ResponseSeriesInner>? _series;
  ListBuilder<GetAdminAnalytics200ResponseSeriesInner> get series =>
      _$this._series ??= ListBuilder<GetAdminAnalytics200ResponseSeriesInner>();
  set series(ListBuilder<GetAdminAnalytics200ResponseSeriesInner>? series) =>
      _$this._series = series;

  GetAdminAnalytics200ResponseCoverageBuilder? _coverage;
  GetAdminAnalytics200ResponseCoverageBuilder get coverage =>
      _$this._coverage ??= GetAdminAnalytics200ResponseCoverageBuilder();
  set coverage(GetAdminAnalytics200ResponseCoverageBuilder? coverage) =>
      _$this._coverage = coverage;

  GetAdminAnalytics200ResponseBuilder() {
    GetAdminAnalytics200Response._defaults(this);
  }

  GetAdminAnalytics200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _summary = $v.summary.toBuilder();
      _series = $v.series.toBuilder();
      _coverage = $v.coverage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalytics200Response other) {
    _$v = other as _$GetAdminAnalytics200Response;
  }

  @override
  void update(void Function(GetAdminAnalytics200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalytics200Response build() => _build();

  _$GetAdminAnalytics200Response _build() {
    _$GetAdminAnalytics200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminAnalytics200Response._(
            range: range.build(),
            summary: summary.build(),
            series: series.build(),
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
        _$failedField = 'coverage';
        coverage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminAnalytics200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
