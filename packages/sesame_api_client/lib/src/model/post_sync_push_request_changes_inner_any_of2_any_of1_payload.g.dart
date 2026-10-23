// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of2_any_of1_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload
    extends PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload {
  @override
  final String? expectedFullCursor;

  factory _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload._(
      {this.expectedFullCursor})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload &&
        expectedFullCursor == other.expectedFullCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload')
          ..add('expectedFullCursor', expectedFullCursor))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload? _$v;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedFullCursor = $v.expectedFullCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload._(
          expectedFullCursor: expectedFullCursor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
