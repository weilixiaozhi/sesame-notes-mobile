// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics200_response_coverage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalytics200ResponseCoverage
    extends GetAdminAnalytics200ResponseCoverage {
  @override
  final DateTime collectionStartedAt;
  @override
  final bool complete;

  factory _$GetAdminAnalytics200ResponseCoverage(
          [void Function(GetAdminAnalytics200ResponseCoverageBuilder)?
              updates]) =>
      (GetAdminAnalytics200ResponseCoverageBuilder()..update(updates))._build();

  _$GetAdminAnalytics200ResponseCoverage._(
      {required this.collectionStartedAt, required this.complete})
      : super._();
  @override
  GetAdminAnalytics200ResponseCoverage rebuild(
          void Function(GetAdminAnalytics200ResponseCoverageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalytics200ResponseCoverageBuilder toBuilder() =>
      GetAdminAnalytics200ResponseCoverageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalytics200ResponseCoverage &&
        collectionStartedAt == other.collectionStartedAt &&
        complete == other.complete;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, collectionStartedAt.hashCode);
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalytics200ResponseCoverage')
          ..add('collectionStartedAt', collectionStartedAt)
          ..add('complete', complete))
        .toString();
  }
}

class GetAdminAnalytics200ResponseCoverageBuilder
    implements
        Builder<GetAdminAnalytics200ResponseCoverage,
            GetAdminAnalytics200ResponseCoverageBuilder> {
  _$GetAdminAnalytics200ResponseCoverage? _$v;

  DateTime? _collectionStartedAt;
  DateTime? get collectionStartedAt => _$this._collectionStartedAt;
  set collectionStartedAt(DateTime? collectionStartedAt) =>
      _$this._collectionStartedAt = collectionStartedAt;

  bool? _complete;
  bool? get complete => _$this._complete;
  set complete(bool? complete) => _$this._complete = complete;

  GetAdminAnalytics200ResponseCoverageBuilder() {
    GetAdminAnalytics200ResponseCoverage._defaults(this);
  }

  GetAdminAnalytics200ResponseCoverageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _collectionStartedAt = $v.collectionStartedAt;
      _complete = $v.complete;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalytics200ResponseCoverage other) {
    _$v = other as _$GetAdminAnalytics200ResponseCoverage;
  }

  @override
  void update(
      void Function(GetAdminAnalytics200ResponseCoverageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalytics200ResponseCoverage build() => _build();

  _$GetAdminAnalytics200ResponseCoverage _build() {
    final _$result = _$v ??
        _$GetAdminAnalytics200ResponseCoverage._(
          collectionStartedAt: BuiltValueNullFieldError.checkNotNull(
              collectionStartedAt,
              r'GetAdminAnalytics200ResponseCoverage',
              'collectionStartedAt'),
          complete: BuiltValueNullFieldError.checkNotNull(
              complete, r'GetAdminAnalytics200ResponseCoverage', 'complete'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
