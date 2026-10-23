// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of15.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnum_fitnessSpace =
    const PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum._(
        'fitnessSpace');

PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'fitnessSpace':
      return _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnum_fitnessSpace;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnum_fitnessSpace,
]);

const PostSyncPushRequestChangesInnerAnyOf15ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf15ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf15ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf15ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf15ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf15ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf15ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf15ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf15ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf15ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf15ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf15ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf15ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf15ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessSpace': 'fitness_space',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_space': 'fitnessSpace',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf15ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf15ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf15ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf15ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf15ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf15ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf15ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf15
    extends PostSyncPushRequestChangesInnerAnyOf15 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf15(
          [void Function(PostSyncPushRequestChangesInnerAnyOf15Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf15Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf15._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf15 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf15Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf15Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf15Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf15 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf15')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf15Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf15,
            PostSyncPushRequestChangesInnerAnyOf15Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf15? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf15Builder() {
    PostSyncPushRequestChangesInnerAnyOf15._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf15Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf15 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf15;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf15Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf15 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf15 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf15._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf15', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
