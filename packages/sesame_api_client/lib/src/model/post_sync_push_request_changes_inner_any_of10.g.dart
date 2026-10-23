// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of10.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnum_memoEntry =
    const PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum._('memoEntry');

PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'memoEntry':
      return _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnum_memoEntry;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnum_memoEntry,
]);

const PostSyncPushRequestChangesInnerAnyOf10ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf10ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf10ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf10ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf10ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf10ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf10ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf10ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'memoEntry': 'memo_entry',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'memo_entry': 'memoEntry',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf10ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf10ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10
    extends PostSyncPushRequestChangesInnerAnyOf10 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf10(
          [void Function(PostSyncPushRequestChangesInnerAnyOf10Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf10Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf10._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf10 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf10Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf10Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf10Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf10 &&
        anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf10')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf10Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf10,
            PostSyncPushRequestChangesInnerAnyOf10Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf10? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf10Builder() {
    PostSyncPushRequestChangesInnerAnyOf10._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf10Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf10 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf10;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf10Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf10 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf10._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf10', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
