// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of13_any_of_payload_run_segments_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
    extends PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner {
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner._(
      {required this.startedAt, this.endedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
      toBuilder() =>
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner')
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
    implements
        Builder<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner? _$v;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder() {
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
        ._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
          other) {
    _$v = other
        as _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner build() =>
      _build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
      _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner._(
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt,
              r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner',
              'startedAt'),
          endedAt: endedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
