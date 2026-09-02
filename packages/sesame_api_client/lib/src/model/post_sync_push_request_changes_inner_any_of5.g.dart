// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of5.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnum_member =
    const PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum._('member');

PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'member':
      return _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnum_member,
]);

const PostSyncPushRequestChangesInnerAnyOf5ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf5ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf5ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf5ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf5ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf5ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf5ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf5ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf5ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf5ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf5ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf5ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf5ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5
    extends PostSyncPushRequestChangesInnerAnyOf5 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf5(
          [void Function(PostSyncPushRequestChangesInnerAnyOf5Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf5Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf5._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf5 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf5Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf5Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf5Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf5 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf5')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf5Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf5,
            PostSyncPushRequestChangesInnerAnyOf5Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf5? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf5Builder() {
    PostSyncPushRequestChangesInnerAnyOf5._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf5Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf5 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf5;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf5Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf5 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf5 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf5._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf5', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
