// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of8.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnum_member =
    const PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum._('member');

PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'member':
      return _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnum_member,
]);

const PostSyncPushRequestChangesInnerAnyOf8ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf8ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf8ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf8ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf8ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf8ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf8ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf8ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf8ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf8ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf8ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf8ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf8ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf8ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf8ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf8ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf8ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf8ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf8ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf8ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf8
    extends PostSyncPushRequestChangesInnerAnyOf8 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf8(
          [void Function(PostSyncPushRequestChangesInnerAnyOf8Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf8Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf8._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf8 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf8Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf8Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf8Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf8 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf8')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf8Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf8,
            PostSyncPushRequestChangesInnerAnyOf8Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf8? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf8Builder() {
    PostSyncPushRequestChangesInnerAnyOf8._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf8Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf8 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf8;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf8Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf8 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf8 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf8._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf8', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
