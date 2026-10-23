// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of9.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnum_memoBook =
    const PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum._('memoBook');

PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'memoBook':
      return _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnum_memoBook;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnum_memoBook,
]);

const PostSyncPushRequestChangesInnerAnyOf9ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf9ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf9ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf9ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf9ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf9ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf9ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf9ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf9ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf9ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf9ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf9ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf9ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf9ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'memoBook': 'memo_book',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'memo_book': 'memoBook',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf9ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf9ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf9ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf9ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf9ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf9ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf9ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf9
    extends PostSyncPushRequestChangesInnerAnyOf9 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf9(
          [void Function(PostSyncPushRequestChangesInnerAnyOf9Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf9Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf9._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf9 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf9Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf9Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf9Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf9 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf9')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf9Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf9,
            PostSyncPushRequestChangesInnerAnyOf9Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf9? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf9Builder() {
    PostSyncPushRequestChangesInnerAnyOf9._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf9Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf9 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf9;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf9Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf9 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf9._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf9', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
