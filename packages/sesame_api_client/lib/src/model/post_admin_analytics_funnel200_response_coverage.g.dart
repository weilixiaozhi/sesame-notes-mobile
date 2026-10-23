// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_analytics_funnel200_response_coverage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAnalyticsFunnel200ResponseCoverage
    extends PostAdminAnalyticsFunnel200ResponseCoverage {
  @override
  final DateTime collectionStartedAt;
  @override
  final bool complete;
  @override
  final int missingContextEvents;

  factory _$PostAdminAnalyticsFunnel200ResponseCoverage(
          [void Function(PostAdminAnalyticsFunnel200ResponseCoverageBuilder)?
              updates]) =>
      (PostAdminAnalyticsFunnel200ResponseCoverageBuilder()..update(updates))
          ._build();

  _$PostAdminAnalyticsFunnel200ResponseCoverage._(
      {required this.collectionStartedAt,
      required this.complete,
      required this.missingContextEvents})
      : super._();
  @override
  PostAdminAnalyticsFunnel200ResponseCoverage rebuild(
          void Function(PostAdminAnalyticsFunnel200ResponseCoverageBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAnalyticsFunnel200ResponseCoverageBuilder toBuilder() =>
      PostAdminAnalyticsFunnel200ResponseCoverageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAnalyticsFunnel200ResponseCoverage &&
        collectionStartedAt == other.collectionStartedAt &&
        complete == other.complete &&
        missingContextEvents == other.missingContextEvents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, collectionStartedAt.hashCode);
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jc(_$hash, missingContextEvents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminAnalyticsFunnel200ResponseCoverage')
          ..add('collectionStartedAt', collectionStartedAt)
          ..add('complete', complete)
          ..add('missingContextEvents', missingContextEvents))
        .toString();
  }
}

class PostAdminAnalyticsFunnel200ResponseCoverageBuilder
    implements
        Builder<PostAdminAnalyticsFunnel200ResponseCoverage,
            PostAdminAnalyticsFunnel200ResponseCoverageBuilder> {
  _$PostAdminAnalyticsFunnel200ResponseCoverage? _$v;

  DateTime? _collectionStartedAt;
  DateTime? get collectionStartedAt => _$this._collectionStartedAt;
  set collectionStartedAt(DateTime? collectionStartedAt) =>
      _$this._collectionStartedAt = collectionStartedAt;

  bool? _complete;
  bool? get complete => _$this._complete;
  set complete(bool? complete) => _$this._complete = complete;

  int? _missingContextEvents;
  int? get missingContextEvents => _$this._missingContextEvents;
  set missingContextEvents(int? missingContextEvents) =>
      _$this._missingContextEvents = missingContextEvents;

  PostAdminAnalyticsFunnel200ResponseCoverageBuilder() {
    PostAdminAnalyticsFunnel200ResponseCoverage._defaults(this);
  }

  PostAdminAnalyticsFunnel200ResponseCoverageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _collectionStartedAt = $v.collectionStartedAt;
      _complete = $v.complete;
      _missingContextEvents = $v.missingContextEvents;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAnalyticsFunnel200ResponseCoverage other) {
    _$v = other as _$PostAdminAnalyticsFunnel200ResponseCoverage;
  }

  @override
  void update(
      void Function(PostAdminAnalyticsFunnel200ResponseCoverageBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAnalyticsFunnel200ResponseCoverage build() => _build();

  _$PostAdminAnalyticsFunnel200ResponseCoverage _build() {
    final _$result = _$v ??
        _$PostAdminAnalyticsFunnel200ResponseCoverage._(
          collectionStartedAt: BuiltValueNullFieldError.checkNotNull(
              collectionStartedAt,
              r'PostAdminAnalyticsFunnel200ResponseCoverage',
              'collectionStartedAt'),
          complete: BuiltValueNullFieldError.checkNotNull(complete,
              r'PostAdminAnalyticsFunnel200ResponseCoverage', 'complete'),
          missingContextEvents: BuiltValueNullFieldError.checkNotNull(
              missingContextEvents,
              r'PostAdminAnalyticsFunnel200ResponseCoverage',
              'missingContextEvents'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
