// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState
    extends PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState {
  @override
  final DateTime? lastGeneratedDate;
  @override
  final DateTime? deletedAt;
  @override
  final BuiltList<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>
      occurrences;

  factory _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState._(
      {this.lastGeneratedDate, this.deletedAt, required this.occurrences})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
      toBuilder() =>
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState &&
        lastGeneratedDate == other.lastGeneratedDate &&
        deletedAt == other.deletedAt &&
        occurrences == other.occurrences;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lastGeneratedDate.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, occurrences.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState')
          ..add('lastGeneratedDate', lastGeneratedDate)
          ..add('deletedAt', deletedAt)
          ..add('occurrences', occurrences))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState? _$v;

  DateTime? _lastGeneratedDate;
  DateTime? get lastGeneratedDate => _$this._lastGeneratedDate;
  set lastGeneratedDate(DateTime? lastGeneratedDate) =>
      _$this._lastGeneratedDate = lastGeneratedDate;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>?
      _occurrences;
  ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>
      get occurrences => _$this._occurrences ??= ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>();
  set occurrences(
          ListBuilder<
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>?
              occurrences) =>
      _$this._occurrences = occurrences;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder() {
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState._defaults(
        this);
  }

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _lastGeneratedDate = $v.lastGeneratedDate;
      _deletedAt = $v.deletedAt;
      _occurrences = $v.occurrences.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState other) {
    _$v = other
        as _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState build() =>
      _build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState _build() {
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState._(
            lastGeneratedDate: lastGeneratedDate,
            deletedAt: deletedAt,
            occurrences: occurrences.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'occurrences';
        occurrences.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState',
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
