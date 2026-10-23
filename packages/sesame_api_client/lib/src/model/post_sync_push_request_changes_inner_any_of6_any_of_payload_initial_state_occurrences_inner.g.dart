// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state_occurrences_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
    extends PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner {
  @override
  final String id;
  @override
  final DateTime? deletedAt;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
      payload;

  factory _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner._(
      {required this.id, this.deletedAt, required this.payload})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
      rebuild(
              void Function(
                      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
      toBuilder() =>
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner &&
        id == other.id &&
        deletedAt == other.deletedAt &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner')
          ..add('id', id)
          ..add('deletedAt', deletedAt)
          ..add('payload', payload))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
    implements
        Builder<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder?
      _payload;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder
      get payload => _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder?
              payload) =>
      _$this._payload = payload;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder() {
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
        ._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _deletedAt = $v.deletedAt;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
          other) {
    _$v = other
        as _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
      build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
      _build() {
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
        _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner',
                'id'),
            deletedAt: deletedAt,
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner',
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
