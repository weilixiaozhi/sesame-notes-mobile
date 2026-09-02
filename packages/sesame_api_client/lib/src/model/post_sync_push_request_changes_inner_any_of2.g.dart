// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnum_category =
    const PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum._('category');

PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'category':
      return _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnum_category;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnum_category,
]);

const PostSyncPushRequestChangesInnerAnyOf2ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf2ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf2ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf2ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf2ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf2ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf2ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf2ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf2ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf2ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'category': 'category',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'category': 'category',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf2ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf2ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf2ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2
    extends PostSyncPushRequestChangesInnerAnyOf2 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf2(
          [void Function(PostSyncPushRequestChangesInnerAnyOf2Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf2Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf2._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf2 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf2Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf2Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf2Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf2 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf2')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf2Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf2,
            PostSyncPushRequestChangesInnerAnyOf2Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf2? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf2Builder() {
    PostSyncPushRequestChangesInnerAnyOf2._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf2Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf2 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf2;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf2Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf2 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf2._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf2', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
