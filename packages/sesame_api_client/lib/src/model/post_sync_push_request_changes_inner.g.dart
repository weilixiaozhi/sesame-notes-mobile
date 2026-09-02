// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerEntityTypeEnum
    _$postSyncPushRequestChangesInnerEntityTypeEnum_member =
    const PostSyncPushRequestChangesInnerEntityTypeEnum._('member');

PostSyncPushRequestChangesInnerEntityTypeEnum
    _$postSyncPushRequestChangesInnerEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'member':
      return _$postSyncPushRequestChangesInnerEntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerEntityTypeEnum>
    _$postSyncPushRequestChangesInnerEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerEntityTypeEnum>(const <PostSyncPushRequestChangesInnerEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerEntityTypeEnum_member,
]);

const PostSyncPushRequestChangesInnerActionEnum
    _$postSyncPushRequestChangesInnerActionEnum_delete =
    const PostSyncPushRequestChangesInnerActionEnum._('delete');

PostSyncPushRequestChangesInnerActionEnum
    _$postSyncPushRequestChangesInnerActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerActionEnum>
    _$postSyncPushRequestChangesInnerActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerActionEnum>(const <PostSyncPushRequestChangesInnerActionEnum>[
  _$postSyncPushRequestChangesInnerActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerEntityTypeEnum>
    _$postSyncPushRequestChangesInnerEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerActionEnum>
    _$postSyncPushRequestChangesInnerActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerEntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerActionEnumSerializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInner
    extends PostSyncPushRequestChangesInner {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInner(
          [void Function(PostSyncPushRequestChangesInnerBuilder)? updates]) =>
      (PostSyncPushRequestChangesInnerBuilder()..update(updates))._build();

  _$PostSyncPushRequestChangesInner._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInner rebuild(
          void Function(PostSyncPushRequestChangesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInner && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'PostSyncPushRequestChangesInner')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerBuilder
    implements
        Builder<PostSyncPushRequestChangesInner,
            PostSyncPushRequestChangesInnerBuilder> {
  _$PostSyncPushRequestChangesInner? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerBuilder() {
    PostSyncPushRequestChangesInner._defaults(this);
  }

  PostSyncPushRequestChangesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInner other) {
    _$v = other as _$PostSyncPushRequestChangesInner;
  }

  @override
  void update(void Function(PostSyncPushRequestChangesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInner build() => _build();

  _$PostSyncPushRequestChangesInner _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInner._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInner', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
