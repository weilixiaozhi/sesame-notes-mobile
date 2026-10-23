// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of15_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload {
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool? restore;
  @override
  final String? expectedFullCursor;

  factory _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, restore.hashCode);
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _restore;
  bool? get restore => _$this._restore;
  set restore(bool? restore) => _$this._restore = restore;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _restore = $v.restore;
      _expectedFullCursor = $v.expectedFullCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload',
              'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload',
              'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
