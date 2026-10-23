// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of_any_of1_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload
    extends PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload {
  @override
  final String? expectedFullCursor;

  factory _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload._(
      {this.expectedFullCursor})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload &&
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
            r'PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload')
          ..add('expectedFullCursor', expectedFullCursor))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload? _$v;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedFullCursor = $v.expectedFullCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload._(
          expectedFullCursor: expectedFullCursor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
